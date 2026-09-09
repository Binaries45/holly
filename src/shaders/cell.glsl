@vs vs
layout(binding=0) uniform vs_params {
    vec2 camera_pos;
    float zoom;
    vec2 viewport_size;
};

in vec2 position;
in vec2 inst_pos;
in vec2 inst_size;
in vec4 inst_color;

out vec4 color;

void main() {
    vec2 pos = position * inst_size + inst_pos + camera_pos;

    gl_Position = vec4(pos, 0.0, 1.0);
    color = inst_color;
}
@end

@fs fs
in vec4 color;
out vec4 frag_color;

void main() {
    frag_color = color;
}
@end

@program cell vs fs
