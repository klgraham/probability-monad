
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
    func prob(predicate: A -> Bool) -> Double {
        return Double(sample(N).filter(predicate).count) / Double(N)
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
    return { x in return x < p }
}

let u = Distribution<Double>(get: nextDouble)
u.get()
u.get()
u.get()

let tf = u.map(lessThan(0.75))
tf.get()
tf.sample(5)

let bernoulli1 = tf.map({(b: Bool) in return b ? 1 : 0})
bernoulli1.sample(10)

let die6 = Distribution<Int>(get: nextInt(min: 1, max: 6))
die6.sample(10)


let pair = die6.flatMap({
    (d1: Int) in return die6.map({ (d2: Int) in return d1 + d2 })
})
pair.sample(7)

// probability computations
print(tf.prob({ (x : Bool) in return x }))


// discrete distributions

//let discreteUniform = 

