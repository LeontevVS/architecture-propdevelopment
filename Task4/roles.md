Неймспейсы по доменам:

1. `sales` — продажи
2. `housing` — ЖКУ
3. `finance` — финансы
4. `data` — обработка данных

| Роль | Права роли | Группы пользователей |
| --- | --- | --- |
| `domain-viewer` | Просмотр состояния приложений, сетевых ресурсов, PVC, событий, квот и RBAC своего домена (`get`, `list`, `watch`). Без Secrets, ConfigMap, логов и подключения к контейнерам. | `<domain>-viewers`: разработчики, аналитики, владельцы продуктов и менеджеры домена. `security-auditors`: специалист ИБ, просмотр всех четырёх доменов. |
| `domain-operator` | Просмотр, создание, изменение и удаление Deployment, StatefulSet, Job, CronJob, Service, ConfigMap, Ingress и HPA; права `domain-viewer`, масштабирование и чтение логов. Только свой домен, без прямого доступа к Secrets и изменения RBAC, ServiceAccount, NetworkPolicy, квот и узлов. Без подключения к контейнерам и проброса портов. | `<domain>-operators`: DevOps-инженеры и инженеры эксплуатации домена. |
| `cluster-configurator` | Просмотр узлов и namespace; изменение узлов (`update`, `patch`): метки, taint, запрет планирования. Без доступа к Secrets и изменения приложений, RBAC и namespace. | `cluster-configurators`: выделенные DevOps-инженеры, отвечающие за узлы кластера. |
| `domain-secret-reader` | Только чтение согласованных Secrets своего домена: `get` с ограничением по `resourceNames`. Без получения списка, наблюдения и изменения секретов. | `<domain>-secret-readers`: уполномоченные инженеры эксплуатации домена. |
| `cluster-admin` | Полный доступ к Kubernetes API, включая Secrets и RBAC. Для первоначальной настройки и аварийного восстановления. | `cluster-admins`: назначенные администраторы из DevOps-инженеров; отдельные административные учётные записи. |

В учебном кластере группы `<domain>-viewers`, `<domain>-operators` и `<domain>-secret-readers` представлены ServiceAccount `viewer`, `operator` и `secret-reader` в namespace домена. Для остальных групп созданы ServiceAccount `cluster-configurator`, `security-auditor` и `task4-admin` в `default`. Привязки назначают роли этим учётным записям напрямую.

Это предлагаемая модель доступа. Она разделяет домены и привилегии с учётом заданий 1–3; прикладные права клиентов и партнёров проверяются самими сервисами. `integration-credentials` — условное имя разрешённого секрета, сам секрет в пустом кластере не создаётся. Права оператора складываются из `domain-viewer` и `domain-operator`.

Оператор может косвенно прочитать секреты своего домена через изменяемые приложения или использовать их ServiceAccount. Поэтому это доверенная группа: RBAC ограничивает прямые запросы к API, но не обеспечивает изоляцию секретов от тех, кто управляет приложениями.

Запуск из корня репозитория: `minikube start -p task4 --driver=docker`, затем `bash Task4/create_users.sh`, `bash Task4/create_roles.sh`, `bash Task4/create_bindings.sh`. Скрипты можно запускать повторно. Учебные учётные записи проверяются администратором через `kubectl --context=task4 auth can-i … --as=system:serviceaccount:<namespace>:<name>`; токен для самостоятельного входа выдаётся командой `kubectl --context=task4 -n <namespace> create token <name>`.

Манифесты находятся в `manifests/*.yml` и сгруппированы по типу и области применения ресурсов. Доменные манифесты применяются в каждый из четырёх namespace через `-n`; общие учётные записи явно размещены в `default`.
