import Foundation

//protocol Distribution {
//    associatedtype A: Comparable
//
//    // sample a single value from the distribution
//    func get() -> A?
//
//    // sample n values from the distribution
//    func sampleOf(_ n: Int) -> [A]
//
//    // Uses a function f: A -> B to Distribution<A> into Distribution<B>
//    func map<B: Comparable>(using f: (A) -> B) -> Distribution
//
//    func flatMap<B: Comparable>(using f: @escaping (A) -> Distribution<B>) -> Distribution
//}



class Distribution<A> {
    
    // sample a single value from the distribution
    var get: () -> A?
    
    init(using get: @escaping () -> A?) {
        self.get = get
    }
    
    // sample n values from the distribution
    func sampleOf(_ n: Int) -> [A] {
        return (1...n).map { x in get()! }
    }
    
    // Uses a function f: A -> B to Distribution<A> into Distribution<B>
    func map<B>(using f: @escaping (A) -> B) -> Distribution<B> {
        let d = Distribution<B>(using: { () -> B? in return nil })
        d.get = {
            () -> B in return f(self.get()!)
        }
        return d
    }
    
    // FlatMaps one Distribution into another
    func flatMap<B>(using f: @escaping (A) -> Distribution<B>) -> Distribution<B> {
        let d = Distribution<B>(using: {() -> B? in return nil})
        d.get = {
            () -> B in return f(self.get()!).get()!
        }
        return d
    }
    
    let N = 10000
    // probability of the predicate being true
    func prob(of predicate: (A) -> Bool) -> Double {
        return Double(sampleOf(N).filter(predicate).count) / Double(N)
    }
    
    // TODO: This function doesn't work just yet. It's returning the same number. Needs tail recursion too. Perhaps this is not possible in Swift?
    private func getGiven(_ predicate: @escaping (A) -> Bool) -> A? {
        let a = get()!
        return predicate(a) ? a : get()
    }
    
    // Returns a distribution where the samples obey the predicate
    func given(_ predicate: @escaping (A) -> Bool) -> Distribution<A> {
        let d: Distribution<A> = Distribution<A>(using: self.get)
        d.get = { () -> A? in
            let a = self.get()!
            return predicate(a) ? a : d.get()
             }
        return d
    }
    
    func mean() -> Double {
        return sampleOf(N).reduce(0, { $0 + Double(String(describing: $1))! }) / Double(N)
    }
    
    func variance() -> Double {
        var sum: Double = 0
        var sqrSum: Double = 0
        
        for x in sampleOf(N) {
            let xx = Double(String(describing: x))!
            sum += xx
            sqrSum += xx * xx
        }
        
        return (sqrSum - sum * sum / Double(N)) / Double(N-1)
    }
    
    func stdDev() -> Double {
        return sqrt(self.variance())
    }
}

// random number generation functions

func nextDouble() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

func nextInt(min: Int, max: Int) -> (() -> Int) {
    assert(max > min)
    return { () in return Int(arc4random_uniform(UInt32((max - min) + 1))) + min }
}


// distributions
let uniform = Distribution<Double>(using: nextDouble)
uniform.mean()


let tf = uniform.map(using: { $0 < 0.75 })
tf.get()
tf.sampleOf(5)

let bernoulli1 = tf.map(using: {$0 ? 1 : 0})
bernoulli1.sampleOf(10)

let die6 = Distribution<Int>(using: nextInt(min: 1, max: 6))
die6.sampleOf(10)


let dice = die6.flatMap(using: {
    (d1: Int) in return die6.map(using: { (d2: Int) in return d1 + d2 })
})
dice.sampleOf(7)



// probability computations
//let discreteUniform =
print("Probability of getting a value above 0.7 from the uniform distribution (0, 1) is ~1/3: \(uniform.prob(of: { $0 > 0.7 })))")

print("Probability of rolling a pair of six-sided dice and getting a 7 is ~1/6: \(dice.prob(of: { $0 == 7 }))")

// This stuff doesn't currently work
print("Probability of rolling a 4 with a six-sided die is ~1/6: \(die6.prob(of: { $0 == 4 }))")
//print("Given a six-sided die that can only roll even numbers, the prob. of rolling a 4 is ~1/3: \(die6.given({ ($0 % 2) == 0 }).prob(of: { $0 == 4 }))")
let evenDice = die6.given({ ($0 % 2) == 0 })

print(evenDice.sampleOf(10))
//print(evenDice.prob({ $0 == 4 }))



