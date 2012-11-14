RAVEN = ./src/raven.js
PARSEURI = ./src/vendor/uri.js
VER = $(shell cat version.txt)
RAVEN_FULL = ./dist/raven-${VER}.js
RAVEN_AMD = ./dist/raven-${VER}.amd.js
RAVEN_MIN = ./dist/raven-${VER}.min.js
TMP = /tmp/raven.min.js

ENDER ?= $(shell echo $${JQUERY-jquery})
COMPRESSOR ?= `which yuicompressor`

#
# Generate the full and compressed and amd distributions
#
raven: raven-full raven-amd raven-min

clean:
	rm -rf dist

# shortcuts
raven-full: ${RAVEN_FULL}
raven-amd: ${RAVEN_AMD}
raven-min: ${RAVEN_MIN}

#
# Build the base instance
${RAVEN_FULL}: ${BASE64} ${CRYPTO} ${PARSEURI} ${RAVEN}
	mkdir -p dist
	cat ${BASE64} ${CRYPTO} ${PARSEURI} ${RAVEN} | \
		sed "s/@VERSION/${VER}/" > ${RAVEN_FULL}

#
# Build the instance meant for use with requirejs
${RAVEN_AMD}: ${RAVEN_FULL}
	> ${RAVEN_AMD} echo "/* Raven.js v${VER} | https://github.com/rdm/raven-js/ */" | \
	>>${RAVEN_AMD} echo "define(['${ENDER}'], function(ender) {"
	>>${RAVEN_AMD} echo "	var build-raven= function build-raven() {"
	>>${RAVEN_AMD} sed "s/^/			/" <${RAVEN_FULL}	
	>>${RAVEN_AMD} echo "		return this.Raven;"
	>>${RAVEN_AMD} echo "	};"
	>>${RAVEN_AMD} echo "	return build-raven.call({ender: ender});"
	>>${RAVEN_AMD} echo "});"


#
# Build the compressed all-in-one file
${RAVEN_MIN}: ${RAVEN_FULL}
	cat ${RAVEN_FULL} | ${COMPRESSOR} --type js > ${RAVEN_MIN}

	# Prepend the tiny header to the compressed file
	echo "/* Raven.js v${VER} | https://github.com/lincolnloop/raven-js/ */" | \
		cat - ${RAVEN_MIN} > ${TMP}
	mv ${TMP} ${RAVEN_MIN}
