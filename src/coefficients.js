import {
    DataTexture, RepeatWrapping, RGBFormat
} from 'three';

function clampedRand(min, max)
{
    let range = max - min;
    let r = Math.random();
    return r * range + min;
}

// 5 coefficients per wave.
function getCoefficientsTexture()
{
    let width = 4; let height = 4;
    let size = width * height;
    let data = new Uint8Array(3 * size);

    let i = 0;
    while (i < 3 * size)
    {
        data[i++] = clampedRand(0, 2 * Math.PI); // angle
        data[i++] = clampedRand(0, 0.1); // frequency
        data[i++] = clampedRand(0, 40); // amplitude
        data[i++] = clampedRand(0, 1.0); // steepness
        data[i++] = clampedRand(0, 5.0); // speed
        data[i++] = 0; // free slot
    }

    let tex = new DataTexture(data, width, height, RGBFormat);
    tex.wrapT = RepeatWrapping;
    tex.wrapS = RepeatWrapping;
    return tex;
}

export { getCoefficientsTexture };
