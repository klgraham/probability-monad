import Foundation

class Distribution<A> {
    
    // Draw a single value from the distribution
    var draw: () -> A?
    
    init(using draw: @escaping () -> A?) {
        self.draw = draw
    }
    
    // sample n values from the distribution
    func sampleOf(_ n: Int) -> [A] {
        return (1...n).map { x in draw()! }
    }
    
    // Uses a function f: A -> B to Distribution<A> into Distribution<B>
    func map<B>(using f: @escaping (A) -> B) -> Distribution<B> {
        let d = Distribution<B>(using: { () -> B? in return nil })
        d.draw = {
            () -> B in return f(self.draw()!)
        }
        return d
    }
    
    // FlatMaps one Distribution into another
    func flatMap<B>(using f: @escaping (A) -> Distribution<B>) -> Distribution<B> {
        let d = Distribution<B>(using: {() -> B? in return nil})
        d.draw = {
            () -> B in return f(self.draw()!).draw()!
        }
        return d
    }
    
    let N = 1_000_000
    // probability of the predicate being true
    func prob(of predicate: (A) -> Bool) -> Double {
        return Double(sampleOf(N).filter(predicate).count) / Double(N)
    }
    
    // Returns a new distribution where the samples obey the predicate
    func given(_ predicate: @escaping (A) -> Bool) -> Distribution<A> {
        let d: Distribution<A> = Distribution<A>(using: self.draw)
        d.draw = { () -> A? in
            let a = self.draw()!
            return predicate(a) ? a : d.draw()
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
print("Mean of Uniform distribution is : \(uniform.mean())")

// transforming uniform into a boolean
let tf = uniform.map(using: { $0 < 0.75 })
print("Drawing five values from a boolean distribution: \(tf.sampleOf(5))")

// transforming boolean into bernoulli
let bernoulli1 = tf.map(using: {$0 ? 1 : 0})
print("Sampling 10 values from a Bernoulli distribution: \(bernoulli1.sampleOf(10))")

// a discrete distribution to represent a six-sided die
let die6 = Distribution<Int>(using: nextInt(min: 1, max: 6))
print("Rolling a six-sided die 10 times: \(die6.sampleOf(10))")

// combining the distributions of two six-sided dice
let dice = die6.flatMap(using: {
    (d1: Int) in return die6.map(using: { (d2: Int) in return d1 + d2 })
})

print("Rolling a pair of six-sided dice: \(dice.sampleOf(7))")

// probability computations

print("Probability of getting a value above 0.7 from the uniform distribution (0, 1) is ~1/3: \(uniform.prob(of: { $0 > 0.7 })))")

print("Probability of rolling a pair of six-sided dice and getting a 7 is ~1/6: \(dice.prob(of: { $0 == 7 }))")

// This stuff doesn't currently work
print("Probability of rolling a 4 with a six-sided die is ~1/6: \(die6.prob(of: { $0 == 4 }))")

// only even rolls from the six-sided die
let evenDice = die6.given({ ($0 % 2) == 0 })
print("Given a six-sided die that can only roll even numbers, the prob. of rolling a 4 is ~1/3: \(evenDice.prob(of: { $0 == 4 }))")
print("Rolling the six-sided die that only rolls even numbers 10 times: \(evenDice.sampleOf(10))")
//print(evenDice.prob({ $0 == 4 }))




