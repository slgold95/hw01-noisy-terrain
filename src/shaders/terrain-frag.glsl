#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform float u_Height; // Added this

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;

in float fs_Sine;
in float height;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.


// 2D random function
float randomFunc(vec2 inVec){
return fract(sin(dot(inVec, vec2(12.9898, 78.233)))* 43758.5453123);

}

// Noise used from https://thebookofshaders.com/11/
float noise(in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = randomFunc(i);
    float b = randomFunc(i + vec2(1.0, 0.0));
    float c = randomFunc(i + vec2(0.0, 1.0));
    float d = randomFunc(i + vec2(1.0, 1.0));

    // Smooth Interpolation
    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}


vec3 getColor(vec2 position, float h){

    // lava if low enough
    if(h < 0.7) {
    float tempNoise = noise(position) * 0.3;
    vec3 tempNoiseVec = vec3(tempNoise);
    vec3 red = vec3(0.7412, 0.1804, 0.0392);
    vec3 brown = vec3(0.3333, 0.2588, 0.0549);
    return mix(red, brown * tempNoiseVec, h);
    }
    // inbetween lava and land
    else if(h >= 0.7 && h < 1.0){
    float tempNoise = noise(position) * 0.3;
    vec3 tempNoiseVec = vec3(tempNoise);
    vec3 lightBrown = vec3(0.5451, 0.4196, 0.3843);
    vec3 brown = vec3(0.3333, 0.2588, 0.0549);
    return mix(lightBrown, brown * tempNoiseVec, h);
    }
    // land
    else {
    float tempNoise = noise(position) * 0.3;
    vec3 tempNoiseVec = vec3(tempNoise);
    vec3 lightBrown = vec3(0.5451, 0.4196, 0.3843);
    vec3 brown = vec3(0.3333, 0.2588, 0.0549);
    vec3 yellow = vec3(0.8745, 0.6824, 0.1608);    
    return mix(brown, lightBrown * tempNoiseVec, h/3.0);
    //return mix(brown, yellow * tempNoiseVec, h/2.0);
    }
}

void main()
{
    // x and y 
    float x = fs_Pos.x + u_PlanePos.x;
    float y = fs_Pos.z + u_PlanePos.y;

    float t = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog
    
    // making color vector from noise function
    float noiseColor = noise(vec2(x, y)) * 0.3;
    vec3 colorVec = vec3(noiseColor);
    vec3 color2 = vec3(0.7412, 0.1804, 0.0392);
    vec3 color3 = vec3(0.3333, 0.2588, 0.0549);

  float noiseTerm = noise(vec2(x,y));
  float g =(smoothstep(0.0, 0.9, pow(smoothstep(0.0, 1.0, noiseTerm), 2.0)), 100.0) 
  * (floor(noiseTerm * 30.0)/30.0) + noiseTerm * 0.1/1.1 * 10.0;
      
    // original checkerish pattern 
    //out_Col = vec4(mix(vec3(0.5 * (fs_Sine + 1.0)), vec3(164.0 / 255.0, 233.0 / 255.0, 1.0), t), 1.0);
    
    // good one
    //out_Col = vec4(mix(mix(color2, color3 * colorVec, height), vec3(164.0 / 255.0, 233.0 / 255.0, 1.0), t), 1.0);

    vec3 blueFog = vec3(164.0 / 255.0, 233.0 / 255.0, 1.0);
    vec3 smog = vec3(0.1686, 0.1647, 0.1647);

    // final coloring
    vec3 mixedCol = getColor(vec2(x,y), height);
    out_Col = vec4(mix(mixedCol, smog, t), 1.0);    
    
    }
