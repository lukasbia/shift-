import ShiftSIL

public final class IRGenFunction {
    public let function: SILFunction
    private let builder: LLVMIRBuilder
    private var values: [Int: IRGenValue] = [:]
    private var blockLabels: [SILBasicBlock.ID: String] = [:]
    private var stringGlobals: [(name: String, bytes: [UInt8])] = []

    init(function: SILFunction, builder: LLVMIRBuilder) {
        self.function = function
        self.builder = builder
    }

    func emit() throws -> [(name: String, bytes: [UInt8])] {
        builder.append("define \(LLVMTypeLowering.lower(function.returnType)) @\(mangle(function.name))(\(function.parameters.map { "\(LLVMTypeLowering.lower($0.value.type)) %arg\($0.value.id)" }.joined(separator: ", "))) {")

        for block in function.blocks { blockLabels[block.id] = block.id.name }

        for block in function.blocks {
            builder.append("\(blockLabels[block.id]!):")
            for instruction in block.instructions {
                try emit(instruction)
            }
        }

        builder.append("}")
        builder.append()
        return stringGlobals
    }

    private func emit(_ instruction: SILInstruction) throws {
        switch instruction {
        case .allocStack(let result):
            let type = LLVMTypeLowering.pointee(result.type)
            builder.append("  \(llvmName(result)) = alloca \(type)")
            values[result.id] = IRGenValue(type: .pointer, operand: llvmName(result))

        case .deallocStack:
            break

        case .load(let result, let address):
            let pointer = try value(address)
            let type = LLVMTypeLowering.lower(result.type)
            builder.append("  \(llvmName(result)) = load \(type), ptr \(pointer.operand)")
            values[result.id] = IRGenValue(type: type, operand: llvmName(result))

        case .store(let stored, let address):
            let storedValue = try value(stored)
            let pointer = try value(address)
            builder.append("  store \(storedValue.type) \(storedValue.operand), ptr \(pointer.operand)")

        case .integerLiteral(let result, let value):
            let type = LLVMTypeLowering.lower(result.type)
            builder.append("  \(llvmName(result)) = add \(type) 0, \(value)")
            values[result.id] = IRGenValue(type: type, operand: llvmName(result))

        case .unsignedIntegerLiteral(let result, let value):
            let type = LLVMTypeLowering.lower(result.type)
            builder.append("  \(llvmName(result)) = add \(type) 0, \(value)")
            values[result.id] = IRGenValue(type: type, operand: llvmName(result))

        case .floatingLiteral(let result, let value):
            let type = LLVMTypeLowering.lower(result.type)
            let bits = type == .floating(32) ? "0x" + String(Float(value).bitPattern, radix: 16).uppercased().paddingLeft(toLength: 8, withPad: "0") : "0x" + String(value.bitPattern, radix: 16).uppercased().paddingLeft(toLength: 16, withPad: "0")
            builder.append("  \(llvmName(result)) = fadd \(type) 0.0, \(bits)")
            values[result.id] = IRGenValue(type: type, operand: llvmName(result))

        case .stringLiteral(let result, let value):
            let bytes = Array(value.utf8) + [0]
            let name = ".str.\(mangle(function.name)).\(result.id)"
            stringGlobals.append((name, bytes))
            let type = LLVMTypeLowering.lower(result.type)
            builder.append("  \(llvmName(result)) = getelementptr inbounds [\(bytes.count) x i8], ptr @\(name), i64 0, i64 0")
            values[result.id] = IRGenValue(type: type, operand: llvmName(result))

        case .characterLiteral(let result, let value):
            let scalar = Array(value.utf8).first ?? 0
            let type = LLVMTypeLowering.lower(result.type)
            builder.append("  \(llvmName(result)) = add \(type) 0, \(scalar)")
            values[result.id] = IRGenValue(type: type, operand: llvmName(result))

        case .booleanLiteral(let result, let value):
            builder.append("  \(llvmName(result)) = xor i1 0, \(value ? 1 : 0)")
            values[result.id] = IRGenValue(type: .integer(1), operand: llvmName(result))

        case .add(let r, let l, let rhs): try binary(r, l, rhs, "add")
        case .subtract(let r, let l, let rhs): try binary(r, l, rhs, "sub")
        case .multiply(let r, let l, let rhs): try binary(r, l, rhs, "mul")
        case .divide(let r, let l, let rhs): try binary(r, l, rhs, "sdiv")
        case .remainder(let r, let l, let rhs): try binary(r, l, rhs, "srem")
        case .bitwiseAnd(let r, let l, let rhs): try binary(r, l, rhs, "and")
        case .bitwiseOr(let r, let l, let rhs): try binary(r, l, rhs, "or")
        case .bitwiseXor(let r, let l, let rhs): try binary(r, l, rhs, "xor")

        case .equal(let r, let l, let rhs): try compare(r, l, rhs, "eq")
        case .notEqual(let r, let l, let rhs): try compare(r, l, rhs, "ne")
        case .lessThan(let r, let l, let rhs): try compare(r, l, rhs, "slt")
        case .lessOrEqual(let r, let l, let rhs): try compare(r, l, rhs, "sle")
        case .greaterThan(let r, let l, let rhs): try compare(r, l, rhs, "sgt")
        case .greaterEqual(let r, let l, let rhs): try compare(r, l, rhs, "sge")

        case .logicalAnd(let r, let l, let rhs): try binary(r, l, rhs, "and")
        case .logicalOr(let r, let l, let rhs): try binary(r, l, rhs, "or")
        case .logicalNot(let result, let operand):
            let value = try self.value(operand)
            builder.append("  \(llvmName(result)) = xor i1 \(value.operand), true")
            values[result.id] = IRGenValue(type: .integer(1), operand: llvmName(result))

        case .negate(let result, let operand):
            let value = try self.value(operand)
            builder.append("  \(llvmName(result)) = sub \(value.type) 0, \(value.operand)")
            values[result.id] = IRGenValue(type: value.type, operand: llvmName(result))

        case .bitwiseNot(let result, let operand):
            let value = try self.value(operand)
            builder.append("  \(llvmName(result)) = xor \(value.type) \(value.operand), -1")
            values[result.id] = IRGenValue(type: value.type, operand: llvmName(result))

        case .convert(let result, let value, let to):
            let source = try self.value(value)
            let target = LLVMTypeLowering.lower(to)
            if source.type == target {
                builder.append("  \(llvmName(result)) = add \(target) 0, \(source.operand)")
            } else if source.type == .pointer || target == .pointer {
                builder.append("  \(llvmName(result)) = bitcast \(source.type) \(source.operand) to \(target)")
            } else {
                builder.append("  \(llvmName(result)) = sitofp \(source.type) \(source.operand) to \(target)")
            }
            values[result.id] = IRGenValue(type: target, operand: llvmName(result))

        case .functionRef(let result, let name, _):
            values[result.id] = IRGenValue(type: .pointer, operand: "@\(mangle(name))")

        case .apply(let result, let function, let arguments):
            let callee = try self.value(function)
            let args = try arguments.map { try self.value($0) }
            let returnType: LLVMType = result.map { LLVMTypeLowering.lower($0.type) } ?? .void
            let signature = args.map { "\($0.type) \($0.operand)" }.joined(separator: ", ")
            if let result {
                builder.append("  \(llvmName(result)) = call \(returnType) \(callee.operand)(\(signature))")
                values[result.id] = IRGenValue(type: returnType, operand: llvmName(result))
            } else {
                builder.append("  call \(returnType) \(callee.operand)(\(signature))")
            }

        case .makeTuple(let result, let elements):
            let resultType = LLVMTypeLowering.lower(result.type)
            if elements.isEmpty {
                values[result.id] = IRGenValue(type: resultType, operand: "undef")
                break
            }
            var current = "undef"
            for (index, element) in elements.enumerated() {
                let value = try self.value(element)
                let temp = index == elements.count - 1 ? llvmName(result) : builder.temporary()
                builder.append("  \(temp) = insertvalue \(resultType) \(current), \(value.type) \(value.operand), \(index)")
                current = temp
            }
            values[result.id] = IRGenValue(type: resultType, operand: llvmName(result))

        case .tupleExtract(let result, let tuple, let index):
            let value = try self.value(tuple)
            let type = LLVMTypeLowering.lower(result.type)
            builder.append("  \(llvmName(result)) = extractvalue \(value.type) \(value.operand), \(index)")
            values[result.id] = IRGenValue(type: type, operand: llvmName(result))

        case .makeArray(let result, let elements):
            let type = LLVMTypeLowering.lower(result.type)
            guard case .array(let elementType) = result.type else {
                builder.append("  \(llvmName(result)) = inttoptr i64 0 to ptr")
                values[result.id] = IRGenValue(type: type, operand: llvmName(result))
                break
            }
            let elementLLVMType = LLVMTypeLowering.lower(elementType)
            let storage = builder.temporary()
            builder.append("  \(storage) = alloca [\(elements.count) x \(elementLLVMType)]")
            for (index, element) in elements.enumerated() {
                let value = try self.value(element)
                let slot = builder.temporary()
                builder.append("  \(slot) = getelementptr inbounds [\(elements.count) x \(elementLLVMType)], ptr \(storage), i64 0, i64 \(index)")
                builder.append("  store \(value.type) \(value.operand), ptr \(slot)")
            }
            let first = builder.temporary()
            builder.append("  \(first) = getelementptr inbounds [\(elements.count) x \(elementLLVMType)], ptr \(storage), i64 0, i64 0")
            builder.append("  \(llvmName(result)) = bitcast ptr \(first) to ptr")
            values[result.id] = IRGenValue(type: type, operand: llvmName(result))

        case .arrayElementAddress(let result, let array, let index):
            let a = try self.value(array); let i = try self.value(index)
            builder.append("  \(llvmName(result)) = getelementptr ptr, ptr \(a.operand), \(i.type) \(i.operand)")
            values[result.id] = IRGenValue(type: .pointer, operand: llvmName(result))

        case .addressOf(let result, let value):
            let source = try self.value(value)
            values[result.id] = IRGenValue(type: .pointer, operand: source.operand)
            builder.append("  \(llvmName(result)) = bitcast ptr \(source.operand) to ptr")

        case .pointerToAddress(let result, let pointer):
            let value = try self.value(pointer)
            builder.append("  \(llvmName(result)) = bitcast ptr \(value.operand) to ptr")
            values[result.id] = IRGenValue(type: .pointer, operand: llvmName(result))

        case .addressToPointer(let result, let address):
            let value = try self.value(address)
            builder.append("  \(llvmName(result)) = bitcast ptr \(value.operand) to ptr")
            values[result.id] = IRGenValue(type: .pointer, operand: llvmName(result))

        case .branch(let target):
            builder.append("  br label %\(blockLabels[target]!)")

        case .conditionalBranch(let condition, let trueTarget, let falseTarget):
            let value = try self.value(condition)
            builder.append("  br i1 \(value.operand), label %\(blockLabels[trueTarget]!), label %\(blockLabels[falseTarget]!)")

        case .returnValue(let value):
            let v = try self.value(value)
            builder.append("  ret \(v.type) \(v.operand)")

        case .returnVoid:
            builder.append("  ret void")

        case .debugValue:
            break
        }
    }

    private func binary(_ result: SILValue, _ left: SILValue, _ right: SILValue, _ operation: String) throws {
        let l = try value(left); let r = try value(right)
        builder.append("  \(llvmName(result)) = \(operation) \(l.type) \(l.operand), \(r.operand)")
        values[result.id] = IRGenValue(type: l.type, operand: llvmName(result))
    }

    private func compare(_ result: SILValue, _ left: SILValue, _ right: SILValue, _ predicate: String) throws {
        let l = try value(left); let r = try value(right)
        builder.append("  \(llvmName(result)) = icmp \(predicate) \(l.type) \(l.operand), \(r.operand)")
        values[result.id] = IRGenValue(type: .integer(1), operand: llvmName(result))
    }

    private func value(_ value: SILValue) throws -> IRGenValue {
        if let existing = values[value.id] { return existing }
        let lowered = LLVMTypeLowering.lower(value.type)
        if function.parameters.contains(where: { $0.value.id == value.id }) {
            let parameter = function.parameters.first(where: { $0.value.id == value.id })!
            let result = IRGenValue(type: lowered, operand: "%arg\(parameter.value.id)")
            values[value.id] = result
            return result
        }
        throw IRGenError.missingValue(value.id)
    }

    private func llvmName(_ value: SILValue) -> String { "%v\(value.id)" }

    private func mangle(_ name: String) -> String {
        let allowed = name.map { $0.isLetter || $0.isNumber || $0 == "_" ? String($0) : "_" }.joined()
        return allowed.isEmpty ? "anonymous" : allowed
    }
}


private extension String {
    func paddingLeft(toLength length: Int, withPad character: Character) -> String {
        guard count < length else { return self }
        return String(repeating: String(character), count: length - count) + self
    }
}
