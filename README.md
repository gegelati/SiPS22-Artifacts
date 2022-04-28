# SiPS 2022 Artifact

This repository is associated to the following publication:

*K. Desnos, T. Bourgoin, N. Sourbier, M. Dardaillon, O. Gesny and M. Pelcat. Ultra-fast AI Inference through C Code Generation for Tangled Program Graphs, In Workshop on Signal Processing Systems, IEEE, 2022*

The repository contains:
* Code and scripts to reproduce the experiments presented in the paper.
* Experimental data and logs produced by the authors and presented in the paper.

## Repository content
```
├─ sips22-artifacts                            # root folder
│  │                                           
│  ├─ gegelati                                 # git submodule pointing to gegelati v1.1.0
│  │  │...                                     
│  │                                           
│  ├─ ale-wrapper                              # git submodule pointing to the Arcade Learning Environment
│  │  │...                                     # wrapper for gegelati.
│  │                                           
│  ├─ data                                     # Experimental data and analysis scripts.
│  │  │                                        
│  │  ├─ Notebook.ipynb                        # Jupyter Notebook with Julia Kernel for plotting interesting 
│  │  │                                        # results from experiments.
│  │  │                                        
│  │  ├─ results.jl                            # Set of Julia functions used to parse logs and results of 
│  │  │                                        # experiments.
│  │  │                                        
│  │  ├─ trainingResults                       # Folder containing pre-trained TPGs for alien, asteroids, 
│  │  │  │                                     # centipede, frostbite, fishing_derby. For each game <g>, 
│  │  │  │                                     # training with 10 different seeds <s> was done.
│  │  │  │                                     
│  │  │  ├─ out.<g>.<s>.std                    # Logs from the training.               
│  │  │  │
│  │  │  ├─ bestPolicyStats.<g>.<s>.t48.md     # Statistics of champion TPGs throughout the 400 generations.
│  │  │  │                      
│  │  │  ├─ out_best.<g>.<s>.t48.dot           # Champion TPG after 400 generations.
│  │  │  │
│  │  │  ├─ out_best_cleaned.<g>.<s>.t48.dot   # Champion cleaned from any useless teams and programs.
│  │  │  │
│  │  │  ├─ stats.codegen.<g>.<s>.log          # Execution statistics for one game of the champion TPG.
│  │  │  │
│  │  │  ├─ analysis.<g>.<s>.txt               # Profiling data generated with gprof on generated code.
│  │  │  │
│  │  │  ├─ log_training_no_nan                # Logs of training scripts for all games and seeds.
│  │  │
│  │  │
│  │  ├─ <platform>                            # Folder containing inference time measurements for the 
│  │  │  │                                     # given platform, using the switch-based code generation.
│  │  │  │
│  │  │  ├─ time.codegen.<g>.<s>.log           # Measured inference time with the generated code.
│  │  │  │
│  │  │  ├─ time.tpg.<g>.<s>.log               # Measured inference time with gegelati.
│  │  │  │
│  │  │  ├─ log_*                              # Logs of the experiment script measuring inference times.
│  │  │  
│  │  │  
│  │  ├─ <platform>Stack                       # Folder containing inference time measurements for the 
│  │  │  │                                     # given platform, using the stack-based code generation.
│  │  │  │
│  │  │  ├─ ...                                # Content of this folder is similar to switch-based folders.
```

## How to reproduce experiments?

0. Clone this repository and its submodules.
   ```bash
   git clone https://github.com/gegelati/SiPS22-Artifacts.git 
   cd SiPS22-Artifacts
   git submodule update --init   
   ```
   
1. Build and install gegelati following instruction from `/SiPS22-Artifacts/gegelati/README.md` 

2. Build and install the Arcade Learning Environment following instructions from 
   `/SiPS22-Artifacts/ale-wrapper/README.md`.
   
3. Run the experiment script for training TPGs, generating code, measuring inference times, 
   and profiling execution of generated code.
   ```bash
   cd ale-wrapper/scripts
   ./codegen_experiments.sh
   ```
   Editing the script is needed to activate/deactivate the profiling of generated code.

If you wish to skip the training process and measure inference times of pre-trained TPGs:

0. Follow steps 0 to 2 from above.
   
1. Comment the lines responsible for training TPG within:
   `/SiPS22-Artifacts/ale-wrapper/scripts/codegen_experiments.sh` 
   
2. Copy the `*.dot` files from `/SiPS22-Artifacts/data/trainingResults/` into the
   `/SiPS22-Artifacts/ale-wrapper/scripts/` folder.

3. Run the `codegen_experiments.sh` script within its folder.

