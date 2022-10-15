echo "Building Grafana Backend"
cd /build

cd deps/grafana
go mod verify
make build-go
