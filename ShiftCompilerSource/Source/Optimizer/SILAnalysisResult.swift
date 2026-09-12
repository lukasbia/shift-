struct SILAnalysisResult<Result> {
    let kind: SILAnalysisKind
    let function: SILFunction
    let value: Result
}
