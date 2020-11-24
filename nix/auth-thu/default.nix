{ nixpkgs ? import <nixpkgs> {} }:

nixpkgs.callPackage ./auth-thu.nix {}
