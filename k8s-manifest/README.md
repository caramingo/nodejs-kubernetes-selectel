# Подключение worker-ноды и запуск приложения в Kubernetes

---

# 1. Подключение worker-ноды к master-ноде

После того как **master** и **worker** ноды подготовлены соответствующими плейбуками, необходимо подключить worker-ноду к master.

На **master-ноде** выполните команду:

```bash
kubeadm token create --print-join-command
```

Команда выведет строку подключения, которую нужно выполнить на **worker-ноде**.

Пример команды:

```bash
kubeadm join 192.168.0.182:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

В вашем случае **IP-адрес, токен и hash будут отличаться.**

---

# 2. Добавление роли worker-ноды

На **master-ноде** проверим список нод:

```bash
kubectl get nodes
```

Пример вывода:

```
NAME               STATUS   ROLES           AGE     VERSION
k8s-server-dpca5   Ready    control-plane   4m12s   v1.31.14
k8s-server-iyhqr   Ready    <none>          47s     v1.31.14
```

Нода с ролью `control-plane` — это **master**.

В данном примере **worker-нода** — `k8s-server-iyhqr`.

Добавим метку worker-ноды:

```bash
kubectl label node k8s-server-iyhqr node-role.kubernetes.io/worker=
```

Проверим результат:

```bash
kubectl get nodes
```

Вывод будет примерно таким:

```
NAME               STATUS   ROLES           AGE     VERSION
k8s-server-dpca5   Ready    control-plane   5m50s   v1.31.14
k8s-server-iyhqr   Ready    worker          2m25s   v1.31.14
```

---

# Настройка домена и TLS

---

# 3. Подготовка домена

Для проекта необходимо иметь домен.

В данном примере используется домен:

```
k8host.ru
```

Домен должен быть **делегирован и активен**.

---

## 3.1 Создание DNS-записи

В панели управления **Selectel**:

```
DNS → Доменные зоны
```

Выберите ваш домен и создайте новую запись типа **A**, которая указывает на внешний IP **master-ноды**.

---

# 4. Выпуск TLS-сертификата

В панели управления **Selectel** перейдите:

```
Безопасность → Менеджер сертификатов → Добавить сертификат → Сертификаты Let's Encrypt
```

Далее:

1. Укажите имя сертификата  
2. Укажите ваш домен  
3. Нажмите **«Выпустить сертификат»**

Через несколько минут сертификат будет создан.

Скачайте два файла:

```
k8host.ru_private_key.pem
k8host.ru_cert.pem
```

Переименуйте их:

```
k8host.ru_private_key.pem → privatkey.pem
k8host.ru_cert.pem → fullchain.pem
```

Скопируйте файлы на **master-ноду**.

---

# Подготовка Kubernetes

---

# 5. Создание namespace и TLS-секрета

На **master-ноде** выполните:

```bash
kubectl create namespace nodeapp
```

Создайте TLS-секрет из сертификатов:

```bash
kubectl -n nodeapp create secret tls k8host-tls \
  --cert=/root/fullchain.pem \
  --key=/root/privatkey.pem
```

---

# 6. Создание Kubernetes-манифестов

Создайте следующие файлы:

```
configmap.yaml
deployment.yaml
service.yaml
```

---

# 7. Применение манифестов

Выполните команды:

```bash
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

# Проверка работы

---

# 8. Проверка состояния

Проверьте состояние подов:

```bash
kubectl -n nodeapp get pods
```

Проверьте сервисы:

```bash
kubectl -n nodeapp get svc
```

Выполните тестовые запросы:

```bash
curl -vk https://<IP_MASTER_NODE>:30500
```

```bash
curl -vk https://k8host.ru:30500
```

---

# Финал

Если команды из пункта **8** выполняются без ошибок и `curl`-запросы возвращают корректный ответ, значит настройка выполнена успешно.

Вы развернули приложение:

- в **кластере Kubernetes**
- в **облаке Selectel**
- с доступом по **доменному имени и TLS**

Теперь можно открыть приложение в браузере:

```
https://k8host.ru:30500
```

---

# Если не работает или что-то пошло не так

Проверка по шагам.

---

## Проверка Secret

```bash
kubectl -n nodeapp get secret k8host-tls
```

```bash
kubectl -n nodeapp get secret k8host-tls -o yaml
```

Должны присутствовать поля:

```
tls.crt
tls.key
```

---

## Проверка ConfigMap

```bash
kubectl -n nodeapp get configmap auth-nginx-conf -o yaml
```

---

## Проверка Deployment

```bash
kubectl -n nodeapp get pods
```

Должен появиться Pod:

```
auth-node-app-xxxxx
```

Статус:

```
2/2 Running
```

Посмотреть где запустились поды:

```bash
kubectl -n nodeapp get pods -o wide
```

---

## Проверка сервиса

```bash
kubectl -n nodeapp get svc
```

Пример вывода:

```
NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
auth-node-app   NodePort   10.98.10.xxx   <none>        30500:30500/TCP   1m
```

---

## Проверка подключения через NodePort

```bash
curl -vk https://<WHITE_IP_NODE>:30500
```

---

## Проверка подключения через DNS

```bash
curl -vk https://k8host.ru:30500
```