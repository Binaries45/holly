{ pkgs ? import <nixpkgs> {} }:

# some bs
pkgs.mkShell {
  packages = with pkgs; [
    zig
    pkg-config
    
    alsa-lib
    libGL
    libX11
    libXi
    libXcursor
  ];
}
