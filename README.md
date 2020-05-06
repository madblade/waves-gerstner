
# Gerstner waves

[Demo](https://madblade.github.io/waves-gerstner/)

![](https://raw.githubusercontent.com/madblade/waves-gerstner/master/img/capture2.jpg)

![](https://raw.githubusercontent.com/madblade/waves-gerstner/master/img/capture.jpg)

## About

Vertex shader implementation of Gerstner waves.

Normal artifacts can be fixed by applying this apporach directly in the fragment,
which would be much more GPU intensive.

## Reference

Vertex-oriented water simulation:
[GPU Gems 1, Ch.1](https://developer.nvidia.com/gpugems/gpugems/part-i-natural-effects/chapter-1-effective-water-simulation-physical-models)

Blending normal maps: [GPU Gems 2, Ch. 18](https://developer.nvidia.com/gpugems/gpugems2/part-ii-shading-lighting-and-shadows/chapter-18-using-vertex-texture-displacement)

GPU-intensive FFT-based ocean simulation: [threejs.ocean2](https://threejs.org/examples/webgl_shaders_ocean2.html)

Skybox reflection from: [threejs.ocean](https://threejs.org/examples/webgl_shaders_ocean.html)
