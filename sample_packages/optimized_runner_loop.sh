#Run optimized runner pipelines in loop using cpdctl
#!/bin/bash

# Loop through all provided arguments
for pipeline in "$@"; do
    # Compile the pipeline for the current argument
    time cpdctl dsjob compile-pipeline --project Project2021 --name "$pipeline"

    # Run the pipeline for the current argument
    time cpdctl dsjob run-pipeline --project Project2021 --name "$pipeline" --wait 3600 --optimize
done
