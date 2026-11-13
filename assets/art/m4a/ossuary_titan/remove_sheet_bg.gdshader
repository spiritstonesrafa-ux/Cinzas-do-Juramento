shader_type canvas_item;

void fragment() {
	vec4 texel = texture(TEXTURE, UV);
	float darkest = min(texel.r, min(texel.g, texel.b));
	float brightest = max(texel.r, max(texel.g, texel.b));
	float saturation = brightest - darkest;
	float background = smoothstep(0.80, 0.96, darkest) * (1.0 - smoothstep(0.035, 0.12, saturation));
	COLOR = vec4(texel.rgb, texel.a * (1.0 - background));
}
