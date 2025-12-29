//go:build freebsd
// +build freebsd

package hid

import "errors"

var errNotSupported = errors.New("HID not supported on FreeBSD")

// Devices returns an empty list on FreeBSD (HID not supported).
func Devices() ([]*DeviceInfo, error) {
	return nil, nil
}

// ByPath returns an error on FreeBSD (HID not supported).
func ByPath(path string) (*DeviceInfo, error) {
	return nil, errNotSupported
}

// Open returns an error on FreeBSD (HID not supported).
func (d *DeviceInfo) Open() (Device, error) {
	return nil, errNotSupported
}
