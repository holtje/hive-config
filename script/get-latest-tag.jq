[
.
|= sort_by(.created_at | fromdate )
| reverse
| .[].metadata.container.tags[]
| select(startswith("sha-"))
][0]
