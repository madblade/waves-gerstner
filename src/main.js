
import { Waves as Water } from './Waves.js';
import { Sky } from './Sky.js';
import {
    CubeCamera,
    DirectionalLight,
    LinearMipmapLinearFilter,
    PerspectiveCamera,
    PlaneBufferGeometry,
    RepeatWrapping,
    Scene,
    WebGLRenderer
} from 'three';
import { TextureLoader } from 'three/src/loaders/TextureLoader';

import waterNormals from './textures/waternormals.jpg';
import {OrbitControls} from 'three/examples/jsm/controls/OrbitControls';
import Stats from 'three/examples/jsm/libs/stats.module';
import { GUI } from 'three/examples/jsm/libs/dat.gui.module';

let container;
let stats;
let camera;
let scene;
let renderer;
let light;
let controls;
let water;

init();
animate();

function init()
{
    //
    container = document.getElementById('container');
    renderer = new WebGLRenderer();
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(window.innerWidth, window.innerHeight);
    container.appendChild(renderer.domElement);

    //
    scene = new Scene();
    camera = new PerspectiveCamera(45, window.innerWidth / window.innerHeight, 1, 20000);
    camera.position.set(0, 100, 400);
    light = new DirectionalLight(0xffffff, 0.8);
    scene.add(light);

    // Water
    let waterGeometry = new PlaneBufferGeometry(500, 500, 100, 100);

    water = new Water(
        waterGeometry,
        {
            textureWidth: 512,
            textureHeight: 512,
            waterNormals: new TextureLoader().load(waterNormals,
                function(texture) {
                    texture.wrapS = texture.wrapT = RepeatWrapping;
                }),
            alpha: 1.0,
            sunDirection: light.position.clone().normalize(),
            sunColor: 0xffffff,
            waterColor: 0x00eeff,

            direction: 0.0,
            frequency: 0.05,
            amplitude: 20.0,
            steepness: 0.7,
            speed: 1.0,
            manyWaves: false
        }
    );
    water.rotation.x = -Math.PI / 2;

    scene.add(water);

    // Skybox
    let sky = new Sky();
    let waterUniforms = sky.material.uniforms;
    waterUniforms.turbidity.value = 10;
    waterUniforms.rayleigh.value = 2;
    waterUniforms.luminance.value = 1;
    waterUniforms.mieCoefficient.value = 0.005;
    waterUniforms.mieDirectionalG.value = 0.8;
    let parameters = {
        distance: 400,
        inclination: 0.3,
        azimuth: 0.205
    };
    let cubeCamera = new CubeCamera(0.1, 1, 512);
    cubeCamera.renderTarget.texture.generateMipmaps = true;
    cubeCamera.renderTarget.texture.minFilter = LinearMipmapLinearFilter;
    scene.background = cubeCamera.renderTarget;

    function updateSun()
    {
        let theta = Math.PI * (parameters.inclination - 0.5);
        let phi = 2 * Math.PI * (parameters.azimuth - 0.5);
        light.position.x = parameters.distance * Math.cos(phi);
        light.position.y = parameters.distance * Math.sin(phi) * Math.sin(theta);
        light.position.z = parameters.distance * Math.sin(phi) * Math.cos(theta);
        sky.material.uniforms.sunPosition.value = light.position.copy(light.position);
        water.material.uniforms.sunDirection.value.copy(light.position).normalize();
        cubeCamera.update(renderer, sky);
    }
    updateSun();

    //
    controls = new OrbitControls(camera, renderer.domElement);
    controls.maxPolarAngle = Math.PI * 0.495;
    controls.target.set(0, 0, 0);
    controls.minDistance = 40.0;
    controls.maxDistance = 1000.0;
    controls.update();

    //
    stats = new Stats();
    container.appendChild(stats.dom);

    // GUI
    let gui = new GUI();

    let folder = gui.addFolder('Sky');
    folder.add(parameters, 'inclination', 0, 0.5, 0.0001).onChange(updateSun);
    folder.add(parameters, 'azimuth', 0, 1, 0.0001).onChange(updateSun);
    // folder.open();

    waterUniforms = water.material.uniforms;

    folder = gui.addFolder('Water');
    // folder.add(waterUniforms.size, 'value', 0.1, 10, 0.1).name('size');
    // folder.add(waterUniforms.alpha, 'value', 0.9, 1, .001).name('alpha');
    folder.add(waterUniforms.direction, 'value', 0, 2 * Math.PI, 0.01).name('wave angle');
    folder.add(waterUniforms.frequency, 'value', 0.0, .08, 0.001).name('frequency');
    folder.add(waterUniforms.amplitude, 'value', 0.0, 40.0, 0.5).name('amplitude');
    folder.add(waterUniforms.steepness, 'value', 0, 1.0, 0.01).name('steepness');
    folder.add(waterUniforms.speed, 'value',     0.0, 5.0, 0.01).name('speed');
    folder.add(waterUniforms.manyWaves, 'value').name('many waves');
    folder.open();

    //
    window.addEventListener('resize', onWindowResize, false);
}

function onWindowResize()
{
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

function animate()
{
    requestAnimationFrame(animate);
    render();
    stats.update();
}

function render()
{
    // let time = performance.now() * 0.001;

    water.material.uniforms.time.value += 1.0 / 120.0;

    renderer.render(scene, camera);
}
