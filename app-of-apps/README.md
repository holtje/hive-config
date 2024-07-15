<!-- markdownlint-disable MD041 -->

| App            | Status                                                                                                                                          |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| app-of-apps    | [![App Status](https://argocd.docwhat.net/api/badge?name=app-of-apps&revision=true)](https://argocd.docwhat.net/applications/app-of-apps)       |
| argo-cd        | [![App Status](https://argocd.docwhat.net/api/badge?name=argo-cd&revision=true)](https://argocd.docwhat.net/applications/argo-cd)               |
| docwhat-blog   | [![App Status](https://argocd.docwhat.net/api/badge?name=docwhat-blog&revision=true)](https://argocd.docwhat.net/applications/docwhat-blog)     |
| metrics        | [![App Status](https://argocd.docwhat.net/api/badge?name=metrics&revision=true)](https://argocd.docwhat.net/applications/metrics)               |
| sealed-secrets | [![App Status](https://argocd.docwhat.net/api/badge?name=sealed-secrets&revision=true)](https://argocd.docwhat.net/applications/sealed-secrets) |
| traefik        | [![App Status](https://argocd.docwhat.net/api/badge?name=traefik&revision=true)](https://argocd.docwhat.net/applications/traefik)               |

# App-of-Apps

> One app to rule them all, and in darkness bind them.

<!--
:;{ echo "| App | Status |" ; echo "| --- | --- |"; for i in app-of-apps/*.yaml; do n=$(yq eval '.metadata.name' - < "$i") ; echo "| ${n} | [\![App Status](https://argocd.docwhat.net/api/badge?name=${n}&revision=true)](https://argocd.docwhat.net/applications/${n}) |"; done } | pbcopy ; pbpaste
-->
