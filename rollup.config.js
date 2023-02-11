import commonjs from "@rollup/plugin-commonjs";
import json from "@rollup/plugin-json";
import { nodeResolve } from "@rollup/plugin-node-resolve";

export default {
  input: "src/download.ts",
  output: {
    dir: "dist/",
    format: "es",
    sourcemap: true,
  },

  plugins: [json(), nodeResolve({ preferBuiltins: true }), commonjs()],
};
