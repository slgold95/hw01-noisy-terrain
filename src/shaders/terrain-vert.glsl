#version 300 es


uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform float u_Height; // Added this
uniform float u_Scale; // Added this

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec3 fs_Pos;
out vec4 fs_Nor;
out vec4 fs_Col;

out float fs_Sine;
out float height;

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float random1( vec3 p , vec3 seed) {
  return fract(sin(dot(p + seed, vec3(987.654, 123.456, 531.975))) * 85734.3545);
}

vec2 random2( vec2 p , vec2 seed) {
  return fract(sin(vec2(dot(p + seed, vec2(311.7, 127.1)), dot(p + seed, vec2(269.5, 183.3)))) * 85734.3545);
}


// Added This
float interpNoise2D(float x, float y){
 float intX = floor(x);
 float fractX = fract(x);
 float intY = floor(y);
 float fractY = fract(y);

 vec2 seedVec = vec2(intX, intY);

 float v1 = random1(vec2(intX, intY), seedVec);
 float v2 = random1(vec2(intX + 1.0f, intY), seedVec);
 float v3 = random1(vec2(intX, intY + 1.0f), seedVec);
 float v4 = random1(vec2(intX + 1.0f, intY + 1.0f), seedVec);

 float i1 = mix(v1, v2, fractX);
 float i2 = mix(v3, v4, fractX);

return mix(i1, i2, fractY);

}

// Added this
float randomFunc(vec2 inVec){
return fract(sin(dot(inVec, vec2(12.9898, 78.233)))* 43758.5453123);
}

// Added this
float interpNoise2D(vec2 vec){
  vec2 i = floor(vec);
  vec2 f = fract(vec);

  float a = randomFunc(i);
  float b = randomFunc(i + vec2(1.0f, 0.0f));
  float c = randomFunc(i + vec2(0.0f, 1.0f));
  float d = randomFunc(i + vec2(1.0f, 1.0f));
 
  vec2 u = f * f * (3.0f - 2.0f * f);

return mix(a, b, u.x) + (c-a)*u.y * (1.0f-u.x) + (d-b) * u.x * u.y;
}


// Added this
float fbm(float x, float y){
  float total = 0.0f;
  float persistence = 0.5f;
  float octaves = 8.0f;

  for(float i = 0.0f; i < octaves; i ++){
      float frequency = pow(2.0f, i);
      float amp = pow(persistence, i);
      total += interpNoise2D(vec2(x * frequency, y * frequency)) * amp;       
  }
  return total;
}


void main()
{
  fs_Pos = vs_Pos.xyz;
  fs_Sine = (sin((vs_Pos.x + u_PlanePos.x) * 3.14159 * 0.1) + cos((vs_Pos.z + u_PlanePos.y) * 3.14159 * 0.1));
  
  float x = vs_Pos.x + u_PlanePos.x;
  float y = vs_Pos.z + u_PlanePos.y;
  
  float noiseTerm = fbm(x / 30.0 * u_Scale, y / 30.0 * u_Scale);
  height = pow(smoothstep(0.0, 0.9, pow(smoothstep(0.0, 1.0, noiseTerm), 2.0)), 100.0) 
  * (floor(noiseTerm * 30.0)/30.0) + noiseTerm * u_Height * 0.1/1.1 * 10.0; 
  
  vec4 modelposition = vec4(vs_Pos.x, height * 3.0, vs_Pos.z, 1.0);
  modelposition = u_Model * modelposition;
  gl_Position = u_ViewProj * modelposition;
}
