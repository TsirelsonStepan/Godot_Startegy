shader_type canvas_item;

uniform sampler2D noise_texture:repeat_enable;
uniform float offset = 0.02;
uniform vec2 scroll = vec2(0.01, 0.01);

void fragment() {
	vec4 pix = texture(noise_texture, UV + scroll + TIME * 0.05);
	vec2 uv = UV;
	uv.x += pix.r * offset;
	uv.y += pix.g * offset;
	COLOR = texture(TEXTURE, uv);
}