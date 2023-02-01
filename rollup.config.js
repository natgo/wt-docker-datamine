import { nodeResolve } from '@rollup/plugin-node-resolve';
import json from '@rollup/plugin-json';
import commonjs from '@rollup/plugin-commonjs';

export default {
	input: 'src/download.ts',
	output: {
		dir: 'dist/',
		format: 'es',
		sourcemap:true
	},
	context:"this",
	
  plugins: [json(),nodeResolve({preferBuiltins: true,}),commonjs()]
};
