Подключение worker-ноды и запуск приложения в Kubernetes
1. Подключение worker-ноды к master-ноду

После того как master и worker ноды подготовлены соответствующими плейбуками, необходимо подключить worker-ноду к master.

На master-нode выполните команду:
kubeadm token create --print-join-command
Команда выведет строку подключения, которую нужно выполнить на worker-нode.
Пример команды:
kubeadm join 192.168.0.182:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
В вашем случае IP-адрес, токен и hash будут отличаться.


2. Добавление роли worker-ноды
На master-нode проверим список нод:
kubectl get nodes
Пример вывода:
NAME               STATUS   ROLES           AGE     VERSION
k8s-server-dpca5   Ready    control-plane   4m12s   v1.31.14
k8s-server-iyhqr   Ready    <none>          47s     v1.31.14

Нода с ролью control-plane — это master.
В данном примере worker-нода — k8s-server-iyhqr.

Добавим метку worker-ноды:
kubectl label node k8s-server-iyhqr node-role.kubernetes.io/worker=
Проверим результат:
kubectl get nodes

Вывод будет примерно таким:
NAME               STATUS   ROLES           AGE     VERSION
k8s-server-dpca5   Ready    control-plane   5m50s   v1.31.14
k8s-server-iyhqr   Ready    worker          2m25s   v1.31.14


Настройка домена и TLS
3. Подготовка домена

Для проекта необходимо иметь домен. В данном примере используется домен: k8host.ru
Домен должен быть делегирован и активен.

3.1 Создание DNS-записи
В панели управления Selectel:
DNS → Доменные зоны, выберете ваш домен. 
Создайте новую запись типа A, которая указывает на внешний IP master-ноды.


4. Выпуск TLS-сертификата
В панели управления Selectel перейдите:
Безопасность → Менеджер сертификатов → Добавить сертификат → Сертификаты Let's Encrypt
Далее: Укажите имя сертификата, укажите ваш домен, нажмите «Выпустить сертификат».
Через несколько минут сертификат будет создан.

Скачайте два файла:
k8host.ru_private_key.pem
k8host.ru_cert.pem

Переименуйте их:
k8host.ru_private_key.pem → privatkey.pem
k8host.ru_cert.pem → fullchain.pem
Скопируйте файлы на master-ноду.


Подготовка Kubernetes
5. Создание namespace и TLS-секрета

На master-нode выполните:
kubectl create namespace nodeapp

Создайте TLS-секрет из сертификатов:
kubectl -n nodeapp create secret tls k8host-tls \
  --cert=/root/fullchain.pem \
  --key=/root/privatkey.pem


6. Создание Kubernetes-манифестов
Создайте следующие файлы:
configmap.yaml
deployment.yaml
service.yaml

7. Применение манифестов
Выполните команды:
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml


Проверка работы
8. Проверка состояния
Проверьте состояние подов:
kubectl -n nodeapp get pods

Проверьте сервисы:
kubectl -n nodeapp get svc

Выполните тестовые запросы:
curl -vk https://<IP_MASTER_NODE>:30500
curl -vk https://k8host.ru:30500


Финал! 
Если команды из пункта 8 выполняются без ошибок и curl-запросы возвращают корректный ответ, значит настройка выполнена успешно.

Вы развернули приложение:
в кластере Kubernetes
в облаке Selectel
с доступом по доменному имени и TLS

Теперь можно открыть приложение в браузере  https://k8host.ru:30500





================================================================================================================================

Если не работает или что то пошло не так. 

проверка по шагам 

Проверка Secret:
kubectl -n nodeapp get secret k8host-tls

kubectl -n nodeapp get secret k8host-tls -o yaml  # Должны быть поля tls.crt и tls.key

Проверка ConfigMap:
kubectl -n nodeapp get configmap auth-nginx-conf -o yaml

Проверка deployment 
kubectl -n nodeapp get pods
Должен появиться Pod auth-node-app-xxxxx
Статус 2/2 Running

Посмотерть где запустились поды 
kubectl -n nodeapp get pods -o wide

Проверка сервиса 
kubectl -n nodeapp get svc
вывод примерный 
NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
auth-node-app   NodePort   10.98.10.xxx   <none>        30500:30500/TCP   1m

Проверка подключения через NodePort
curl -vk https://<WHITE_IP_NODE>:30500


Проверка подключения через DNS
curl -vk https://k8host.ru:30500
