shader_type sky;

uniform vec3 skyColour : source_color;
uniform vec3 horizonColour : source_color;
uniform vec3 cloudColour : source_color;
uniform float fade;

uniform sampler2D cloud_texture;
uniform sampler2D cloud_texture2;
uniform vec2 cloud_direction;
uniform vec2 cloud_direction2;
uniform vec2 cloud_scale;
uniform float cloud_distance;
uniform float cloud_speed;
uniform float cloud_speed2;

void sky() {
	float col = clamp(EYEDIR.y/ fade, 0.0, 1.0);
	vec3 finalColour = mix (horizonColour, skyColour, col);
	
	vec2 sky_uv = EYEDIR.xz / EYEDIR.y;

	vec3 clouds = texture(cloud_texture, sky_uv * cloud_scale + TIME * cloud_direction * cloud_speed).rgb - texture(cloud_texture2, sky_uv * cloud_scale + TIME * cloud_direction2 * cloud_speed2).rgb;
	clouds = clouds - smoothstep(0.0, EYEDIR.y, cloud_distance);
	clouds = clamp(clouds, 0.0, 1.0); 

	finalColour += clouds * cloudColour;
	
	COLOR = finalColour * LIGHT0_ENERGY;
}
