#!/bin/sh

expected="$(cat ./test/replace-image-output.yaml)"
actual="$(./bin/replace-image image-name new-tag <./test/replace-image-input.yaml)"

if [ "${actual}" != "${expected}" ]; then
    echo "Test failed!"
    echo "Expected output:"
    echo "${expected}"
    echo "Actual output:"
    echo "${actual}"
    exit 1
fi

cp ./test/replace-image-input.yaml "${TMPDIR}/tmp.yaml"
./bin/replace-image image-name new-tag "${TMPDIR}/tmp.yaml"

actual="$(cat "${TMPDIR}/tmp.yaml")"

rm -f "${TMPDIR}/tmp.yaml"

if [ "${actual}" != "${expected}" ]; then
    echo "Test failed: ${TMPDIR}/tmp.yaml"
    echo "Expected output:"
    echo "${expected}"
    echo "Actual output:"
    echo "${actual}"
    exit 1
fi
