shader_type canvas_item;

void fragment() {
	vec4 texel = texture(TEXTURE, UV);
	float darkest = min(texel.r, min(texel.g, texel.b));
	float brightest = max(texel.r, max(texel.g, texel.b));
	float chroma = brightest - darkest;
	// Fire is strongly colored; the neutral bright checkerboard is the baked background.
	if (darkest > 0.68 && chroma < 0.085) {
		discard;
	}
	COLOR = texel * COLOR;
}
