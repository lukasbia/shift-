struct SILLoopInfo {
    let loops: [SILLoop]

    func containing(_ block: SILBasicBlock.ID) -> SILLoop? {
        loops
            .filter { $0.contains(block) }
            .min { $0.count < $1.count }
    }

    func topLevelLoops() -> [SILLoop] {
        loops.filter { outer in
            !loops.contains { inner in
                inner.header != outer.header &&
                inner.blocks.isStrictSubset(of: outer.blocks)
            }
        }
    }
}
