# DSPB---Dynamic-Spatial-Predicted-Background
Codes for DSPB foreground\background separation method

The usage of this folder and any of its content is protected by copyright laws.
To use the codes for any other usage than academic please contact me at ytocker@gmail.com

DSPB is a novel method for video foreground/background separation using static cameras.
The method exploits pixel correlations, where each allegedly represents a static source, to reconstruct the scene of
how it would look like affected only by light sources, the background. Foreground objects by there nature are objects the pass through the scene, therefore the act a stochastoc disturbance, rather than something the can be modeled by a light source.
Since video analysis is dealing with huge amounts of data, most mwthods described in the literature are computationally exhaustive making algorithms output an offline analysis.
Some methods are much faster and work online, but they usually serve as an anomlay detection sysytem that detects many outliers in the prescene of illumination changed (sudden or gradual).
Our model is physically derived from the illumination model of the scene, yielding robustness to illumination changes.


The method main strengths are:
* Low computation load -> real-time performance.
* Initial background model created as soon as the 5th frame.
* Model update mechanism that keeps the background model updated to the content of the background that can evolve during a video stream.
* Handels illumination changes.
