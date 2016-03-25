
import Foundation

protocol Stochastic {
    associatedtype NumberType
    func get() -> NumberType
    func sample(n: Int) -> [NumberType]
}

protocol TypeGeneric {
    associatedtype ParameterType
    var p: ParameterType { get }
}

//protocol Transformable {
//    associatedtype A
//    associatedtype B
//    func map<B>(f: A -> B) -> Transformable
//}

struct UniformDoubleDist: Stochastic {
    // Returns a uniform double on [0,1]
    func get() -> Double {
        return drand48()
    }
    
    func sample(n: Int) -> [Double] {
        return (1...n).map { x in get() }
    }
}

let uniform = UniformDoubleDist()
uniform.get()
uniform.sample(2)

struct BooleanDist: Stochastic, TypeGeneric {
    var p: Double
    let uniform = UniformDoubleDist()
    
    func get() -> Bool {
        return uniform.get() < p
    }
    
    func sample(n: Int) -> [Bool] {
        return uniform.sample(n).map { x in x < p }
    }
}

let tf = BooleanDist(p: 0.8)
tf.sample(10)

struct BernoulliDist: Stochastic, TypeGeneric {
    var p: Double
    let uniform = UniformDoubleDist()
    
    func get() -> Int {
        return oneOrZero(uniform.get() < p)
    }
    
    func sample(n: Int) -> [Int] {
        return uniform.sample(n).map { x in x < p }.map { x in oneOrZero(x) }
    }
        
    private func oneOrZero(x: Bool) -> Int {
        if (x) {
            return 1
        } else {
            return 0
        }
    }
}

let bernoulli = BernoulliDist(p: 0.5)
bernoulli.sample(10)

