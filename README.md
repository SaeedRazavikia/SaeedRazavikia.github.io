# SwitchComp (shareable minimal package)

This folder is a **self-contained subset** of the MMSE / PCIe SerDes log workflow: batch Simulink runs, saved `Data/*.mat` logs, and the main **SNRvsMSE2func** analysis (16-bit sum metrics: hard, MMSE multi-vector, MAP).

**Handing this to someone new:** point them to **`docs/READ_THIS_FIRST.md`** first (reading order, one-line data flow, troubleshooting table).

## Architecture (how pieces connect)

1. **Configuration** — `runConfig.m` defines named **scenarios**: which Simulink model to open, Tx voltage list, number of seeds, output `.mat` filename under `Data/`, and (for noisy scenarios) SNR, channel loss, and sample time used to set the Band-Limited White Noise block.
2. **Simulation** — `generate_and_save_logs.m` runs one **scenario** from `runConfig.m` / `userSettings.m` and calls **`runSwitchComp('generate', ...)`**, which in turn calls either `batchSimulateSerDesLink` or `batchSimulateNoisySerDesLink`. Each run stores `logsout` in `allRuns(k).logs`.
3. **Post-processing** — `analyzeSerDesRunLog` turns one run’s logs into aligned symbol streams and statistics. `analyzeAllSerDesRuns` applies that to a subset of runs (e.g. all runs at one Tx voltage).
4. **Estimation** — `estimateMmseSum16BitAcrossRuns`, `evaluateHardSum16BitAcrossRuns`, and `evaluateMapSum16BitAcrossRuns` combine multiple runs into **sum-of-16-bit-words** metrics (default: sum across runs), for comparison of soft vs hard vs MAP-style decoding.
5. **Example driver** — `SNRvsMSE2func.m` calls **`runSwitchComp('analyze', ...)`**, which loads the saved MAT and plots MSE and BER vs Tx voltage for the three approaches.

For a concise file index inside MATLAB, run `help Contents`. For pipeline details and required Simulink logged signal names, see **`utils/README.txt`**.

**Slides / handout (expanded, with MathWorks links + figure guidance):** **`docs/SwitchComp_Slides_and_Handout.md`**

**Cross-run estimators (Hard vs MMSE vs MAP, math + data flow):** **`docs/SwitchComp_CrossRun_Estimators.md`**

## Directory layout

| Location | Role |
|----------|------|
| Project root (`*.m` except `utils/`) | Runnable scripts and `runConfig` / `setupProject` |
| `utils/` | Analysis and batch-simulation helpers |
| `models/` | `SerDes_Base_Link.slx` and `Noisy_SerDes_Base_Link.slx` (not in Git; use `linkExampleModels` or copy manually) |
| `Data/` | Generated `.mat` archives (ignored by Git if `.gitignore` is used) |
| `data/` | Lowercase folder reserved for auxiliary inputs (created by `linkExampleModels`) |

## What to copy when sharing

Zip or copy **only** the `SwitchComp` directory. Recipients do **not** need the rest of the parent project.

**Private GitHub:** To finish or verify a push of this tree, use **`docs/GitHub_private_repo_sync.md`** (file manifest + `git` commands).

## Easiest way to start

1. Set MATLAB **Current Folder** to **`SwitchComp`**.
2. Type **`runSwitchComp`** in the Command Window.
3. Use the menu: **link models → generate logs → analyze**. Open **`userSettings.m`** from the menu when you want to change defaults (scenarios, optional pick lists, `nEstim`, MAP `sigma2`).

Day to day you usually only edit **`userSettings.m`** (scenarios, **`crossRunFunc`** / **`crossRunFuncName`** for Hard/MAP analysis, `nEstim`, MAP `sigma2`). When you add a new scenario name, update **`runConfig.m`** and the **`localScenarioList`** function inside **`runSwitchComp.m`** so the menu, validation, and scripts stay aligned.

## Setup for the recipient (step by step)

1. Set **Current Folder** to **`SwitchComp`** (contains `setupProject.m`).
2. Run **`linkExampleModels`** once, or use **runSwitchComp → link models**. That copies the two `.slx` files when possible and creates **`models/`**, **`Data/`**, and **`data/`**. If copy fails, see **`models/README.txt`**.
3. Either run **`runSwitchComp`** and follow the menu, or edit **`userSettings.m`** and run **`generate_and_save_logs.m`** then **`SNRvsMSE2func.m`** in order.

Keep **`runConfig.m`**, **`runSwitchComp.m`** (`localScenarioList`), and **`userSettings.m`** consistent: analysis must point at a MAT file you have already generated for that scenario.

## File reference

| Path | Purpose |
|------|--------|
| `Contents.m` | MATLAB `help Contents`: one-line index of this package. |
| `setupProject.m` | Adds `utils`, `data`, `models` to the path. |
| `runConfig.m` | Named scenarios and `Data/*.mat` filenames. |
| `runSwitchComp.m` | **Start here:** menu plus all generate/analyze implementation. |
| `userSettings.m` | **Edit this** for default scenarios and optional scenario menus. |
| `generate_and_save_logs.m` | Clears workspace, then calls `runSwitchComp('generate', ...)`. |
| `SNRvsMSE2func.m` | Calls `runSwitchComp('analyze', ...)`. |
| `utils/*.m` | Helpers (see table below and **`utils/README.txt`**). |
| `linkExampleModels.m` | Copies `.slx` from the example tree into `models/` when possible. |
| `models/README.txt` | What to place in `models/`; optional **SerDes Designer → Simulink** notes (`pcie6_ibis_txrx`). |
| `docs/READ_THIS_FIRST.md` | Short path for a new person: order to read docs, one-line flow, FAQ-style triage. |
| `.gitignore` | Ignores `Data/`, `slprj/`, `*.asv` if you use Git. |

### Utility reference (`utils/`)

| File | Role |
|------|------|
| `batchSimulateSerDesLink.m` | Batch-run clean SerDes link, return `allRuns` with logs. |
| `batchSimulateNoisySerDesLink.m` | Batch-run noisy link (noise block parameters). |
| `analyzeSerDesRunLog.m` | One simulation log → metrics + `txSymEval` / `rxObsEval` for estimators. |
| `analyzeAllSerDesRuns.m` | Run `analyzeSerDesRunLog` on every element of `allRuns`. |
| `estimateMmseSum16BitAcrossRuns.m` | Multi-vector MMSE / MAP sum in 16-bit word domain. |
| `evaluateHardSum16BitAcrossRuns.m` | Hard-decision cross-run function (e.g. sum) on 16-bit words. |
| `evaluateMapSum16BitAcrossRuns.m` | MAP-style soft aggregation for sum-type functions across runs. |
| `pam4MapSumEstimator.m` | Standalone PAM4 MAP sum estimator (3-arg); optional alongside MAP script. |
| `analyzeMaxAcrossRuns16bit.m` | Hard max of decoded 16-bit words across runs. |
| `analyzeMaxAcrossRuns16bit_MAP.m` | Vector-observation MAP max (from parent `SNRvsMSE2max.m`). |
| `SNRvsMSE2max.m` | Example driver for max Hard vs MAP analysis. |

The parent **`General-MMSE-PCIe/utils/`** folder still uses the original filenames if you need to compare or sync.

## Requirements

MATLAB with **Simulink**, models and signal logging compatible with the original example (logged names such as `rxOut`, `S1`, PAM4 threshold statistics, as used in **`analyzeSerDesRunLog.m`**).
