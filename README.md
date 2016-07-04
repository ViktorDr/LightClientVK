# LightClientVK
test myself by knowledge VKSDK

Три раздела:
1. Мои друзья
2. Моя стена
3. Новости

Поддержка iOS: 8 и 9

 В разделе «Моя стена» работает скролл вниз + при нажатии на пост с картинками можно детально просмотреть картинки
 
 Многопоточную загрузку картинок с помощью GCD успел сделать только в разделе друзья, все остальные картинки подгружаются c помощью SDWebImage
 
 Кеширование картинок успел сделать только с помощью SDWebImage, но если бы делал без этой библиотеки, то в базе хранил бы url картинки и в Documents хранил бы картинку с названием как url
 
 С MOGenerator разобраться не успел: действуя по инструкциям классы не создавались и я решил не тратить время:
 https://habrahabr.ru/post/185894/
 http://bryanlor.com/blog/ios-tutorial-how-add-and-configure-mogenerator-xcode-5
 https://raptureinvenice.com/getting-started-with-mogenerator/
