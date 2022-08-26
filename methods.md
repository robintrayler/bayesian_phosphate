---
bibliography: /Users/robintrayler/Zotero/ref_library.bib
csl: /Users/robintrayler/Zotero/styles/geology.csl
mainfont: "Helvetica"
geometry: margin=1.0in
---

<!--  pandoc -s methods.md --pdf-engine=xelatex --citeproc -o method.pdf -->
# Methods

We developed a Bayesian regression model to estimate the temperature and δ^18^O of seawater from our δ^18^O~PO4~ values. We assume that δ^18^O~PO4~ is normally distributed around a mean *μ*, with standard deviation *σ*.    

$$\delta^{18}O_{PO4} \sim \mathcal{N}(\mu, \sigma)$$

Where μ is determined by the relationship among temperature (T), δ^18^O~water~, and δ^18^O~PO4~ as proposed by @longinelli1973, and the dispersion term (σ) is estimated from the data. 

$$\mu = \delta^{18}O_{water} - \frac{T - 111.4}{4.3}$$

Bayesian models attempt to estimate the probable values of unknown parameters (in our case temperature and δ^18^O~water~) based on data (δ^18^O~PO4~) and prior information about these parameters. This relationship is formalized in Bayes' theorem where:

$$P(T, \delta^{18}O_{water} | \delta^{18}O_{PO_{4}}) = \frac{P(\delta^{18}O_{PO_{4}}|T, \delta^{18}O_{water})}{(\delta^{18}O_{PO_{4}})} \times P(T, \delta^{18}O_{water})$$

The first term on the right-hand side of equation 3 is known as the likelihood and is the conditional probability of our data, given a proposed temperature and value of δ^18^O~water~. The second term represents our prior beliefs about these parameters. In our case, since sharks have clear habitat temperature preferences we define the prior probability of temperature as $T \sim \mathcal{U}(5, 30)$ which essentially covers the habitat-temperature range of all modern sharks species (**Rachel put your references here**). We also defined the prior probability of δ^18^O~water~ as $\delta^{18}O_{water} \sim \mathcal{N}(\mu = -0.5, \sigma = 0.5)$, which is the variability of a modern well-mixed ocean with a slightly more negative mean to reflect lower polar ice volumes in the Miocene and Pliocene (**Rachel put your references here**).

Combining these equations gives the final joint probability of: 

$$P(T, \delta^{18}O_{water} | \delta^{18}O_{PO_{4}}) = \mathcal{N}(\mu, \sigma) \times \mathcal{U}(5, 30) \times \mathcal{N}(-0.5, 0.5)$$

To estimate each parameter, we used Markov Chain Monte Carlo (MCMC) with an adaptive Metropolis algorithm [@haario2001]. We binned our δ^18^O~PO4~ data by latitude, age, and ocean basin (see Figure 1) and generated a posterior sample of temperature, δ^18^O~water~ and σ by running our model for 100,000 iterations and discarding the first 10,000 to allow for model burn-in. R code for our modeling is available in the appendix.

![Map of sample localities.](map.pdf)

# Results 

Our posterior estimates of temperature versus latitude are shown in Figure 2 and our posterior estimates δ^18^O~water~ are shown in Figure 3. Summary statistics are shown in Table 1. 



![Plot of posterior temperature estimates vs latitude. The dashed lined are the limits of the uniform prior distribution for temperature. The light grey curve is the modern latitudinal gradient in mean surface (0 - 500m) seawater temperature, from the data set of @gaschmidt1999.](temperature.pdf)


![Plot of posterior δ^18^O~water~ estimates vs latitude. The red and black dashed lines are the mean and two standard deviations of the prior distribution.](d18Ow.pdf)

basin               |age      | δ^18^O~water~| ±1σ| temperature| ±1σ| σ| ±1σ|
|:-------------------|:--------|----------:|--------:|---------:|-------:|----------:|--------:|
|South Pacific       |Miocene  |      -0.54|     0.51|     14.99|    2.32|       1.07|     0.11|
|Central Pacific     |Pliocene |      -0.50|     0.50|     22.63|    2.26|       0.60|     0.16|
|S. Central Atlantic |Miocene  |      -0.51|     0.53|     25.01|    2.30|       0.39|     0.06|
|N. Central Atlantic |Pliocene |      -0.96|     0.39|     28.14|    1.51|       1.69|     0.39|
|N. Central Atlantic |Miocene  |      -0.49|     0.48|     24.08|    2.10|       0.80|     0.07|
|East Pacific        |Miocene  |      -0.50|     0.50|     15.12|    3.36|       1.36|     0.67|
|West Atlantic       |Pliocene |      -0.49|     0.50|     12.30|    2.48|       0.93|     0.26|
|West Atlantic       |Miocene  |      -0.50|     0.49|     13.69|    3.21|       1.31|     0.66|
|Paratethys          |Miocene  |      -0.54|     0.55|     17.53|    2.41|       1.41|     0.07|

# References {-}
:::{#refs}
:::