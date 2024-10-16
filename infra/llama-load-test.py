import requests
import statistics
import datetime

eval_per_second_vals = []
prompt_eval_per_second_vals = []
vram_use_vals = []
vram_gtt_use_vals = []

# initial warmup round which is not considered in benchmarks since it includes stuff like load time of the model
requests.post("http://localhost:11434/api/generate", json={
        "model": "llama3.2",
        "prompt": "How much wood would a wood chuck chuck if a wood chuck could chuck wood?",
        "options": {
            "seed": 123,
        },
        "stream": False
    })

for idx in range(0,10):
    response = requests.post("http://localhost:11434/api/generate", json={
        "model": "llama3.2",
        "prompt": "How much wood would a wood chuck chuck if a wood chuck could chuck wood?",
        "options": {
            "seed": 123,
        },
        "stream": False
    })
    if response.status_code != 200:
        print("Bad response from API")
        raise Exception(response.status_code, response.text)

    data = response.json()
    # durations from API are given in nanoseconds (1x10^-9)
    eval_per_second = data["eval_count"] / (data["eval_duration"] / 1000000000)
    prompt_eval_per_second = data["prompt_eval_count"] / (data["prompt_eval_duration"] / 1000000000)

    # print(f"Eval Token/second={eval_per_second}")
    # print(f"Prompt Eval Token/second={prompt_eval_per_second}")

    eval_per_second_vals.append(eval_per_second)
    prompt_eval_per_second_vals.append(prompt_eval_per_second)

    with open(f"/sys/class/drm/card1/device/mem_info_vram_used", 'r') as f:
        vram_usage = int(f.read().strip()) / 1024 / 1024
        vram_use_vals.append(vram_usage)
        # print(f"VRAM Usage: {vram_usage} MB")

    with open(f"/sys/class/drm/card1/device/mem_info_gtt_used", 'r') as f:
        vram_usage = int(f.read().strip()) / 1024 / 1024
        vram_gtt_use_vals.append(vram_usage)
        # print(f"VRAM GTT Usage: {vram_usage} MB")

    if idx % 5 == 0:
        print(f'{datetime.datetime.now(datetime.UTC)} finish iteration {idx}')


print("Test result table")
print("| KPI | Avg | Max | Min | Stdev |")
print("| --- | --- | --- | --- | ---   |")

avg = statistics.mean(eval_per_second_vals)
stdev = statistics.stdev(eval_per_second_vals)

print(f"| Eval token/s | {avg} | {max(eval_per_second_vals)} | {min(eval_per_second_vals)} | {stdev} |")

avg = statistics.mean(prompt_eval_per_second_vals)
stdev = statistics.stdev(prompt_eval_per_second_vals)

print(f"| Prompt token/s | {avg} | {max(prompt_eval_per_second_vals)} | {min(prompt_eval_per_second_vals)} | {stdev} |")


avg = statistics.mean(vram_use_vals)
stdev = statistics.stdev(vram_use_vals)

print(f"| VRAM use (MB) | {avg} | {max(vram_use_vals)} | {min(vram_use_vals)} | {stdev} |")

avg = statistics.mean(vram_gtt_use_vals)
stdev = statistics.stdev(vram_gtt_use_vals)

print(f"| VRAM GTT use (MB) | {avg} | {max(vram_gtt_use_vals)} | {min(vram_gtt_use_vals)} | {stdev} |")