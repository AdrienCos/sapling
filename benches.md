# Benchmarks

## UV + PDM in UV's venv

```sh
$ hyperfine --warmup 1 "docker buildx build -t sapling:dev --no-cache ."
Benchmark 1: docker buildx build -t sapling:dev --no-cache .
  Time (mean ± σ):     12.812 s ±  0.657 s    [User: 0.097 s, System: 0.053 s]
  Range (min … max):   11.807 s … 13.626 s    10 runs
```

## Previous + dynamic requirements generation

```sh
 hyperfine --warmup 1 "docker buildx build -t sapling:dev --no-cache ."
Benchmark 1: docker buildx build -t sapling:dev --no-cache .
  Time (mean ± σ):     12.260 s ±  0.442 s    [User: 0.093 s, System: 0.049 s]
  Range (min … max):   11.713 s … 12.878 s    10 runs
```

## Previous + direct build with `pyproject-build`

```sh
$ hyperfine --warmup 1 "docker buildx build -t sapling:dev --no-cache ."
Benchmark 1: docker buildx build -t sapling:dev --no-cache .
  Time (mean ± σ):     10.032 s ±  0.267 s    [User: 0.095 s, System: 0.051 s]
  Range (min … max):    9.840 s … 10.670 s    10 runs```
```

## Using `pdm-backend` as build backend

```sh
$ hyperfine --warmup 1 "docker buildx build -t sapling:dev --no-cache ."
Benchmark 1: docker buildx build -t sapling:dev --no-cache .
  Time (mean ± σ):      8.682 s ±  0.221 s    [User: 0.095 s, System: 0.047 s]
  Range (min … max):    8.396 s …  9.032 s    10 runs
  ```

## Using a cache mount for the `uv` installs

```sh
hyperfine --warmup 1 "docker buildx build -t sapling:dev --no-cache ."
Benchmark 1: docker buildx build -t sapling:dev --no-cache .
  Time (mean ± σ):      8.637 s ±  0.145 s    [User: 0.101 s, System: 0.057 s]
  Range (min … max):    8.438 s …  8.917 s    10 runs
```
