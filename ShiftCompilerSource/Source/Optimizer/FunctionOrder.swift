struct SILFunctionOrder {
    let functions: [SILFunction]

    init(module: SILModule) {
        let summaries = SILBasicCalleeAnalysis().analyze(module)
        let byName = Dictionary(
            uniqueKeysWithValues: module.functions.map { ($0.name, $0) }
        )

        var result: [SILFunction] = []
        var visited: Swift.Set<String> = []

        func visit(_ function: SILFunction) {
            guard visited.insert(function.name).inserted else {
                return
            }

            for callee in summaries[function.name]?.directCallees ?? [] {
                if let function = byName[callee] {
                    visit(function)
                }
            }

            result.append(function)
        }

        for function in module.functions {
            visit(function)
        }

        functions = result
    }
}
