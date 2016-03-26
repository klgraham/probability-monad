
import Foundation

struct Distribution<A> {
    var get: () -> A?
    
    func sample(n: Int) -> [A] {
        return (1...n).map { x in get()! }
    }
    
    func map<B>(f: A -> B) -> Distribution<B> {
        var d = Distribution<B>(get: {() -> Optional<B> in return nil})
        d.get = {
            (Void) -> B in return f(self.get()!)
        }
        return d
    }
    
    // FlatMaps one Distribution into another
    func flatMap<B>(f: A -> Distribution<B>) -> Distribution<B> {
        var d = Distribution<B>(get: {() -> Optional<B> in return nil})
        d.get = {
            (Void) -> B in return f(self.get()!).get()!
        }
        return d
    }
    
    let N = 10000
    // probability of the predicate being true
    func prob(predicate: A -> Bool) -> Double {
        return Double(sample(N).filter(predicate).count) / Double(N)
    }
    
    // Samples from the new distribution so that the result matches the predicate
    func given(predicate: A -> Bool) -> Distribution<A> {
        var d = self
        let a = d.get()!
        d.get = { predicate(a) ? a : self.get() }
        return d
    }
    
    func mean() -> Double {
        return sample(N).reduce(0, combine: { $0 + Double(String($1))! }) / Double(N)
    }
    
    func variance() -> Double {
        var sum: Double = 0
        var sqrSum: Double = 0
        
        for x in sample(N) {
            let xx = Double(String(x))!
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

func nextInt(min min: Int, max: Int) -> ((Void) -> Int) {
    assert(max > min)
    return { () in return Int(arc4random_uniform(UInt32((max - min) + 1))) + min }
}


// transformation functions

func lessThan(p: Double) -> (Double -> Bool) {
    return { $0 < p }
}

let u = Distribution<Double>(get: nextDouble)
u.get()
u.get()
u.get()

//u.mean()


let tf = u.map(lessThan(0.75))
tf.get()
tf.sample(5)

let bernoulli1 = tf.map({$0 ? 1 : 0})
bernoulli1.sample(10)

let die6 = Distribution<Int>(get: nextInt(min: 1, max: 6))
die6.sample(10)


let pair = die6.flatMap({
    (d1: Int) in return die6.map({ (d2: Int) in return d1 + d2 })
})
pair.sample(7)

// probability computations
//print(tf.prob({ $0 }))


// discrete distributions

//let discreteUniform = 

