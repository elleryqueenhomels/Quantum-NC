// Copyright (c) Microsoft Corporation. All rights reserved. Licensed under the
// Microsoft Software License Terms for Microsoft Quantum Development Kit Libraries
// and Samples. See LICENSE in the project root for license information.
namespace SystemTestJWOptimizedES {
    open Microsoft.Quantum.Simulation;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Chemistry;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Chemistry.JordanWigner;
    open Microsoft.Quantum.Research.Chemistry;
    open Microsoft.Quantum.Measurement;

    // Test phase of PP term.
    operation PPTermFromGeneralHamiltonianTestOp (identity : Double, data : JWOptimizedHTerms) : Unit {

        let time = 1.0;

        using ((qubits, parityQubit) = (Qubit[3], Qubit())) {
            
            // Create |00> + |10>
            let qubitSys = qubits[0 .. Length(qubits) - 2];
            H(qubits[0]);
            JWOptimizedApplyTrotterStep(data, time, time, parityQubit, qubitSys);
            AssertPhase(-0.5 * time, qubits[0], 1E-10);
            ResetAll(qubits);

            // Create |00> + |01>
            H(qubits[1]);
            JWOptimizedApplyTrotterStep(data, time, time, parityQubit, qubitSys);
            AssertPhase(-0.0 * time, qubits[1], 1E-10);
            ResetAll(qubits);
            let ctrl = qubits[Length(qubits) - 1];
            H(ctrl);
            X(qubitSys[0]);
            (Controlled (Exp([PauliI], time * identity, _)))([ctrl], [qubits[0]]);
            (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit, _)))([ctrl], qubitSys);
            AssertPhase(-0.5 * time, ctrl, 1E-10);
            ResetAll(qubits + [parityQubit]);
        }
    }
    
    
    // Test hopping from site A to site B.
    operation PQTermABFromGeneralHamiltonianTestOp (data : JWOptimizedHTerms) : Unit {
        
        // Test probability
        let time = 0.5 * PI();
        mutable arrPrep = new Int[4];
        set arrPrep = [0, 1, 2, 3];
        mutable arrMeasure = new Int[4];
        set arrMeasure = [1, 0, 2, 3];
        
        using (parityQubit = Qubit[1]) {
            
            using (qubits = Qubit[4]) {
                
                // Create |1000>
                for (idx in 0 .. 3) {
                    X(qubits[arrPrep[idx]]);
                    JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], qubits);
                    AssertProb([PauliZ], [qubits[arrMeasure[idx]]], One, 1.0, "PQTermTest probability failed.", 1E-10);
                    ResetAll(qubits + parityQubit);
                }
            }
            
            // Test phase
            using (qubitsC = Qubit[5]) {
                
                // Create |1000>(|0>+|1>)
                let ctrl = qubitsC[4];
                H(ctrl);
                X(qubitsC[arrPrep[0]]);
                
                // Create |1000>|0>+ i|0100>|1>
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitsC[0 .. 3]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.5, "PQTermTest probability failed.", 1E-10);
                
                // Create |1000>|0>+ i|1000>|1>
                CNOT(ctrl, qubitsC[0]);
                CNOT(ctrl, qubitsC[1]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.0, "PQTermTest probability failed.", 1E-10);
                AssertPhase(-0.25 * PI(), ctrl, 1E-10);
                ResetAll(qubitsC + parityQubit);
            }
        }
    }
    
    
    // Test hopping from site A to site C
    operation PQTermACFromGeneralHamiltonianTestOp (data : JWOptimizedHTerms) : Unit {
        
        // Test probability
        let time = 0.5 * PI();
        mutable arrPrep = new Int[4];
        set arrPrep = [0, 2, 3, 5];
        mutable arrMeasure = new Int[4];
        set arrMeasure = [2, 0, 3, 5];
        
        using (parityQubit = Qubit[1]) {
            
            using (qubits = Qubit[6]) {
                
                // Create |100000>
                for (idx in 0 .. 3) {
                    X(qubits[arrPrep[idx]]);
                    JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], qubits);
                    AssertProb([PauliZ], [qubits[arrMeasure[idx]]], One, 1.0, "PQTermTest probability failed.", 1E-10);
                    ResetAll(qubits + parityQubit);
                }
            }
            
            // Test phase
            using (qubitsC = Qubit[7]) {
                
                // Create |1000>(|0>+|1>)
                let ctrl = qubitsC[6];
                H(ctrl);
                X(qubitsC[arrPrep[0]]);
                
                // Create |10000>|0>+ i|00100>|1>
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitsC[0 .. 5]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.5, "PQTermTest probability failed.", 1E-10);
                
                // Create |10000>|0>+ i|10000>|1>
                CNOT(ctrl, qubitsC[0]);
                CNOT(ctrl, qubitsC[2]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.0, "PQTermTest probability failed.", 1E-10);
                AssertPhase(-0.25 * PI(), ctrl, 1E-10);
                ResetAll(qubitsC + parityQubit);
                H(ctrl);
                X(qubitsC[arrPrep[0]]);
                X(qubitsC[1]);
                
                // Create |11000>|0>- i|01100>|1>
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitsC[0 .. 5]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.5, "PQTermTest probability failed.", 1E-10);
                
                // Create |11000>|0>- i|11000>|1>
                CNOT(ctrl, qubitsC[0]);
                CNOT(ctrl, qubitsC[2]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.0, "PQTermTest probability failed.", 1E-10);
                AssertPhase(0.25 * PI(), ctrl, 1E-10);
                ResetAll(qubitsC + parityQubit);
            }
        }
    }
    
    
    // Test phase of PP term.
    operation PQQPTermFromGeneralHamiltonianTestOp (identity : Double, data : JWOptimizedHTerms) : Unit {
        
        let time = 1.0;
        
        using (qubits = Qubit[5]) {
            
            using (parityQubit = Qubit[1]) {
                let ctrl = qubits[Length(qubits) - 1];
                let qubitSys = qubits[0 .. Length(qubits) - 2];
                
                // Create |1100>(|0>+|1>);
                H(ctrl);
                X(qubitSys[0]);
                X(qubitSys[1]);
                
                // Create |1100>(|0>+e^{i t}|1>);
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitSys);
                (Controlled (Exp([PauliI], time * identity, _)))([ctrl], [qubitSys[0]]);
                AssertPhase(-0.5 * time, ctrl, 1E-10);
                ResetAll(qubits + parityQubit);
                
                // Create |1110>(|0>+|1>);
                H(ctrl);
                X(qubitSys[0]);
                X(qubitSys[1]);
                X(qubitSys[2]);
                
                // Create |1100>(|0>+e^{i t}|1>);
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitSys);
                (Controlled (Exp([PauliI], time * identity, _)))([ctrl], [qubitSys[0]]);
                AssertPhase(-0.5 * time, ctrl, 1E-10);
                ResetAll(qubits + parityQubit);
                
                // Create |1111>(|0>+|1>);
                H(ctrl);
                X(qubitSys[0]);
                X(qubitSys[1]);
                X(qubitSys[2]);
                X(qubitSys[3]);
                
                // Create |1100>(|0>+e^{i t}|1>);
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitSys);
                (Controlled (Exp([PauliI], time * identity, _)))([ctrl], [qubitSys[0]]);
                AssertPhase(-0.5 * time, ctrl, 1E-10);
                ResetAll(qubits + parityQubit);
            }
        }
    }
    
    
    operation PQQRTermFromGeneralHamiltonianTestOp (data : JWOptimizedHTerms) : Unit {
        
        // Test probability
        mutable time = (4.0 * 0.5) * PI();
        mutable arrPrep = new Int[4];
        set arrPrep = [0, 2, 1, 3];
        mutable arrMeasure = new Int[4];
        set arrMeasure = [2, 0, 3, 1];
        
        using (qubits = Qubit[4]) {
            
            using (parityQubit = Qubit[1]) {
                
                // Create |1000>
                for (idx in 0 .. 3) {
                    X(qubits[arrPrep[idx]]);
                    JWOptimizedApplyTrotterStep(data, time, 0.1 * time, parityQubit[0], qubits);
                    AssertProb([PauliZ], [qubits[arrMeasure[idx]]], One, 0.0, "PQQRTermTest a probability failed.", 1E-10);
                    ResetAll(qubits);
                }
                
                // Create |1100>
                set time = PI();
                X(qubits[arrPrep[0]]);
                X(qubits[1]);
                JWOptimizedApplyTrotterStep(data, time, 0.1 * time, parityQubit[0], qubits);
                AssertProb([PauliZ], [qubits[arrMeasure[0]]], One, 1.0, "PQQRTermTest b probability failed.", 0.01);
                ResetAll(qubits);
                
                // Create |1001>
                set time = PI();
                X(qubits[arrPrep[0]]);
                X(qubits[3]);
                JWOptimizedApplyTrotterStep(data, time, 0.1 * time, parityQubit[0], qubits);
                AssertProb([PauliZ], [qubits[arrMeasure[0]]], One, 0.0, "PQQRTermTest c probability failed.", 0.01);
                ResetAll(qubits);
            }
        }
    }
    
    
    operation PQRSTermFromGeneralHamiltonianTestOp (data : JWOptimizedHTerms) : Unit {
        
        // Test probability
        mutable time = 1.0;
        mutable prob = Sin(time) * Sin(time);
        
        using (qubits = Qubit[4]) {
            
            using (parityQubit = Qubit[1]) {
                
                // Create |1100>
                X(qubits[0]);
                X(qubits[1]);
                JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], qubits);
                AssertProb([PauliZ], [qubits[2]], One, prob, "PQRSTermTest a probability failed.", 1E-10);
                AssertProb([PauliZ], [qubits[3]], One, prob, "PQRSTermTest b probability failed.", 1E-10);
                ResetAll(qubits + parityQubit);
            }
        }
    }
    
    
    // Test phase of PP term.
    operation PPTermFromLiquidOrbitalTestOp (identity : Double, data : JWOptimizedHTerms) : Unit {
        
        let time = 1.0;
        
        using (qubits = Qubit[3]) {
            
            using (parityQubit = Qubit[1]) {
                
                // Create |00> + |10>
                let qubitSys = qubits[0 .. Length(qubits) - 2];
                H(qubits[0]);
                JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], qubitSys);
                AssertPhase(-0.5 * time, qubits[0], 1E-10);
                ResetAll(qubits + parityQubit);
                
                // Create |00> + |01>
                H(qubits[1]);
                JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], qubitSys);
                AssertPhase(-0.5 * time, qubits[1], 1E-10);
                ResetAll(qubits + parityQubit);
                let ctrl = qubits[Length(qubits) - 1];
                H(ctrl);
                X(qubitSys[0]);
                (Controlled (Exp([PauliI], time * identity, _)))([ctrl], [qubits[0]]);
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitSys);
                AssertPhase(-0.5 * time, ctrl, 1E-10);
                ResetAll(qubits + parityQubit);
            }
        }
    }
    
    
    // Test hopping from site A to site B.
    operation PQTermABFromLiquidOrbitalTestOp (data : JWOptimizedHTerms) : Unit {
        
        // Test probability
        let time = 0.5 * PI();
        mutable arrPrep = new Int[4];
        set arrPrep = [0, 1, 2, 3];
        mutable arrMeasure = new Int[4];
        set arrMeasure = [1, 0, 3, 2];
        
        using (parityQubit = Qubit[1]) {
            
            using (qubits = Qubit[4]) {
                
                // Create |1000>
                for (idx in 0 .. 3) {
                    X(qubits[arrPrep[idx]]);
                    JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], qubits);
                    AssertProb([PauliZ], [qubits[arrMeasure[idx]]], One, 1.0, "PQTermTest probability failed.", 1E-10);
                    ResetAll(qubits + parityQubit);
                }
            }
            
            // Test phase
            using (qubitsC = Qubit[5]) {
                
                // Create |1000>(|0>+|1>)
                let ctrl = qubitsC[4];
                H(ctrl);
                X(qubitsC[arrPrep[0]]);
                
                // Create |1000>|0>+ i|0100>|1>
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitsC[0 .. 3]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.5, "PQTermTest probability failed.", 1E-10);
                
                // Create |1000>|0>+ i|1000>|1>
                CNOT(ctrl, qubitsC[0]);
                CNOT(ctrl, qubitsC[1]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.0, "PQTermTest probability failed.", 1E-10);
                AssertPhase(-0.25 * PI(), ctrl, 1E-10);
                ResetAll(qubitsC + parityQubit);
            }
        }
    }
    
    
    // Test hopping from site A to site C
    operation PQTermACFromLiquidOrbitalTestOp (data : JWOptimizedHTerms) : Unit {
        
        // Test probability
        let time = 0.5 * PI();
        mutable arrPrep = new Int[4];
        set arrPrep = [0, 2, 3, 5];
        mutable arrMeasure = new Int[4];
        set arrMeasure = [2, 0, 5, 3];
        
        using (parityQubit = Qubit[1]) {
            
            using (qubits = Qubit[6]) {
                
                // Create |100000>
                for (idx in 0 .. 3) {
                    X(qubits[arrPrep[idx]]);
                    JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], qubits);
                    AssertProb([PauliZ], [qubits[arrMeasure[idx]]], One, 1.0, "PQTermTest probability failed.", 1E-10);
                    ResetAll(qubits + parityQubit);
                }
            }
            
            // Test phase
            using (qubitsC = Qubit[7]) {
                
                // Create |1000>(|0>+|1>)
                let ctrl = qubitsC[6];
                H(ctrl);
                X(qubitsC[arrPrep[0]]);
                
                // Create |10000>|0>+ i|00100>|1>
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitsC[0 .. 5]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.5, "PQTermTest probability failed.", 1E-10);
                
                // Create |10000>|0>+ i|10000>|1>
                CNOT(ctrl, qubitsC[0]);
                CNOT(ctrl, qubitsC[2]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.0, "PQTermTest probability failed.", 1E-10);
                AssertPhase(-0.25 * PI(), ctrl, 1E-10);
                ResetAll(qubitsC + parityQubit);
                H(ctrl);
                X(qubitsC[arrPrep[0]]);
                X(qubitsC[1]);
                
                // Create |11000>|0>- i|01100>|1>
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitsC[0 .. 5]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.5, "PQTermTest probability failed.", 1E-10);
                
                // Create |11000>|0>- i|11000>|1>
                CNOT(ctrl, qubitsC[0]);
                CNOT(ctrl, qubitsC[2]);
                AssertProb([PauliZ], [qubitsC[arrMeasure[0]]], One, 0.0, "PQTermTest probability failed.", 1E-10);
                AssertPhase(0.25 * PI(), ctrl, 1E-10);
                ResetAll(qubitsC + parityQubit);
            }
        }
    }
    
    
    // Test phase of PP term.
    operation PQQPTermFromLiquidOrbitalTestOp (identity : Double, data : JWOptimizedHTerms) : Unit {
        
        let time = 1.0;
        
        using (parityQubit = Qubit[1]) {
            
            using (qubits = Qubit[5]) {
                let ctrl = qubits[Length(qubits) - 1];
                let qubitSys = qubits[0 .. Length(qubits) - 2];
                
                // Create |1100>(|0>+|1>);
                H(ctrl);
                X(qubitSys[0]);
                X(qubitSys[1]);
                
                // Create |1100>(|0>+e^{i t / 2}|1>);
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitSys);
                (Controlled (Exp([PauliI], time * identity, _)))([ctrl], [qubitSys[0]]);
                AssertPhase(-0.5 * time, ctrl, 1E-10);
                ResetAll(qubits);
                
                // Create |1110>(|0>+|1>);
                H(ctrl);
                X(qubitSys[0]);
                X(qubitSys[1]);
                X(qubitSys[2]);
                
                // Create |1100>(|0>+e^{i 2 t}|1>);
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitSys);
                (Controlled (Exp([PauliI], time * identity, _)))([ctrl], [qubitSys[0]]);
                AssertPhase(-1.0 * time, ctrl, 1E-10);
                ResetAll(qubits);
                
                // Create |1111>(|0>+|1>);
                H(ctrl);
                X(qubitSys[0]);
                X(qubitSys[1]);
                X(qubitSys[2]);
                X(qubitSys[3]);
                
                // Create |1100>(|0>+e^{i 4 t}|1>);
                (Controlled (JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], _)))([ctrl], qubitSys);
                (Controlled (Exp([PauliI], time * identity, _)))([ctrl], [qubitSys[0]]);
                AssertPhase(-2.0 * time, ctrl, 1E-10);
                ResetAll(qubits);
            }
        }
    }
    
    
    operation PQQRTermFromLiquidOrbitalTestOp (data : JWOptimizedHTerms) : Unit {
        
        // Test probability
        mutable time = (4.0 * 0.5) * PI();
        mutable arrPrep = new Int[4];
        set arrPrep = [0, 1, 2, 3];
        mutable arrMeasure = new Int[4];
        set arrMeasure = [1, 0, 3, 2];
        
        using (parityQubit = Qubit[1]) {
            
            using (qubits = Qubit[4]) {
                
                // Create |1000>
                for (idx in 0 .. 3) {
                    X(qubits[arrPrep[idx]]);
                    JWOptimizedApplyTrotterStep(data, time, 0.1 * time, parityQubit[0], qubits);
                    AssertProb([PauliZ], [qubits[arrMeasure[idx]]], One, 0.0, "PQQRTermTest a probability failed.", 1E-10);
                    ResetAll(qubits);
                }
                
                // Create |1010>
                set time = (0.5 * PI()) / Sqrt(2.0);
                X(qubits[arrPrep[0]]);
                X(qubits[2]);
                JWOptimizedApplyTrotterStep(data, time, 0.01 * time, parityQubit[0], qubits);
                AssertProb([PauliZ], [qubits[arrMeasure[0]]], One, 0.5, "PQQRTermTest b probability failed.", 0.01);
                ResetAll(qubits);
                
                // Create |1001>
                set time = (0.5 * PI()) / Sqrt(2.0);
                X(qubits[arrPrep[0]]);
                X(qubits[3]);
                JWOptimizedApplyTrotterStep(data, time, 0.01 * time, parityQubit[0], qubits);
                AssertProb([PauliZ], [qubits[arrMeasure[0]]], One, 0.25, "PQQRTermTest c probability failed.", 0.01);
                ResetAll(qubits);
            }
        }
    }
    
    
    operation PQRSTermFromLiquidOrbitalTestOp (data : JWOptimizedHTerms) : Unit {
        
        // Test probability
        mutable time = 1.0;
        mutable prob = Sin(time) * Sin(time);
        
        using (parityQubit = Qubit[1]) {
            
            using (qubits = Qubit[4]) {
                
                // Create |1010>
                X(qubits[0]);
                X(qubits[2]);
                JWOptimizedApplyTrotterStep(data, time, time, parityQubit[0], qubits);
                AssertProb([PauliZ], [qubits[1]], One, prob, "PQRSTermTest a probability failed.", 1E-10);
                AssertProb([PauliZ], [qubits[3]], One, prob, "PQRSTermTest b probability failed.", 1E-10);
                ResetAll(qubits);
            }
        }
    }
    
    
    operation JWOptimizedApplyTrotterStep (data : JWOptimizedHTerms, time : Double, trotterStepSize : Double, parityQubit : Qubit, qubits : Qubit[]) : Unit {
        
        body (...) {
            let generatorSystem = JWOptimizedGeneratorSystem(data);
            let evolutionGenerator = EvolutionGenerator(JordanWignerOptimizedFermionEvolutionSet(parityQubit), generatorSystem);
            let trotterOrder = 1;
            let simulationAlgorithm = TrotterSimulationAlgorithm(trotterStepSize, trotterOrder);
            simulationAlgorithm!(time, evolutionGenerator, qubits);
        }
        
        adjoint invert;
        controlled distribute;
        controlled adjoint distribute;
    }
    
}


