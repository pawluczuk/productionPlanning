# productionPlanning
Mean-absolute deviation production-planning model (AMPL + CPLEX)

## Project structure
#### /Sprawozdanie
Contains LaTeX source files + compiled PDF file for documentation in Polish language: production planning task, Markowitz model theory, mathematical model, effective results in profit-risk space, effective results for maximum profit and minmum risk

#### /markowitz
Contains mathematical model written in AMPL. `markowitz.mod` contains a model (defined sets, params, variables and subjects); `productionData.dat` and `scenarios.dat` contains data that model is filled with. `script.run` creates a final loop in which minimal profit is set while looking for minimum risk result. 

Model is based on two articles:
* http://web.stanford.edu/class/msande348/papers/Konno_MeanAbDev_ManSciMay91.pdf
* http://www.ia.pw.edu.pl/~wogrycza/publikacje/artykuly/krakow.pdf
