import {
    DataTexture, NearestFilter, RepeatWrapping, RGBFormat
} from 'three';

function getWave(j, jMax)
{
    let amp = 1.5 / Math.pow(j, 2.0);
    let frq = (0.002 + ((j - 1) / jMax) * 0.18) / 0.06;
    return {
        steepness: (j + 2) / (jMax + 2),
        speed: 2.0 * (j + 1) / jMax,
        angle: j * Math.PI * 2.0 / jMax,
        frequency: frq,
        amplitude: amp
    };
}

// 5 coefficients per wave.
function getCoefficientsTexture()
{
    let width = 8; let height = 8;
    let size = width * height;
    let data = new Uint8Array(3 * size);

    let i = 0;
    let j = 0;
    while (i < 3 * size)
    {
        j++;
        let w = getWave(j, size);
        data[i++] = 255 * w.steepness;
        data[i++] = 255 * w.speed;
        data[i++] = 0.0;

        data[i++] = 255.0 * w.angle;
        data[i++] = 255.0 * w.frequency;
        data[i++] = 255.0 * w.amplitude;
    }

    let tex = new DataTexture(data, width, height, RGBFormat);
    tex.generateMipmaps = false;
    tex.minFilter = NearestFilter;
    tex.magFilter = NearestFilter;
    tex.wrapT = RepeatWrapping; // should not be useful
    tex.wrapS = RepeatWrapping;
    return tex;
}

export { getCoefficientsTexture };
