struct SILCaptureInfo: Hashable {
    let capturedValues: Swift.Set<SILValue>

    var capturesAnything: Bool {
        !capturedValues.isEmpty
    }
}

struct SILCaptureAnalysis {
    let name = "CaptureAnalysis"

    func analyze(_ function: SILFunction) -> SILCaptureInfo {
        var defined: Swift.Set<Int> = []
        var captured: Swift.Set<SILValue> = []

        for block in function.blocks {
            for instruction in block.instructions {
                for value in instruction.definedValues {
                    defined.insert(value.id)
                }

                for value in instruction.usedValues {
                    if !defined.contains(value.id) {
                        captured.insert(value)
                    }
                }
            }
        }

        return SILCaptureInfo(capturedValues: captured)
    }
}
