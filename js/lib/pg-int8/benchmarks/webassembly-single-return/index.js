'use strict';

const fs = require('fs');
const path = require('path');

const binary = fs.readFileSync(path.join(__dirname, 'parseint8.wasm'));
const {parseLow, parseHigh} = new WebAssembly.Instance(new WebAssembly.Module(binary)).exports;

module.exports = buffer => {
	let high = buffer.readInt32BE(0);
	let low = buffer.readUInt32BE(4);
	let sign = '';

	if (high < 0) {
		high = ~high + (low === 0);
		low = (~low + 1) >>> 0;
		sign = '-';
	}

	if (high === 0) {
		return sign + low;
	}

	const lowDecimalN = parseLow(high, low);
	const highDecimal = parseHigh(high, low, lowDecimalN);
	const lowDecimal = ('' + (1000000000 + lowDecimalN)).slice(1);

	return sign + highDecimal + lowDecimal;
};
