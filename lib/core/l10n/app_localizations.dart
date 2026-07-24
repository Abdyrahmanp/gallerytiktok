// lib/core/l10n/app_localizations.dart
// Comprehensive 4-language localization (Turkish, English, Turkmen, Russian).
// No code generation needed — fully hand-written with Flutter standard API.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('tr'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String _t(String key) =>
      _strings[locale.languageCode]?[key] ??
      _strings['tr']![key] ??
      key;

  // ── Navigation ────────────────────────────────────────────────
  String get discover        => _t('discover');
  String get favorites       => _t('favorites');
  String get settings        => _t('settings');

  // ── Actions ───────────────────────────────────────────────────
  String get like            => _t('like');
  String get liked           => _t('liked');
  String get hide            => _t('hide');
  String get share           => _t('share');
  String get mute            => _t('mute');
  String get sound           => _t('sound');
  String get cancel          => _t('cancel');
  String get retry           => _t('retry');
  String get restore         => _t('restore');

  // ── Feed ──────────────────────────────────────────────────────
  String get loadingVideos   => _t('loadingVideos');
  String get noVideos        => _t('noVideos');
  String get noVideosDesc    => _t('noVideosDesc');
  String get galleryError    => _t('galleryError');
  String get nextVideo       => _t('nextVideo');

  // ── Settings ─────────────────────────────────────────────────
  String get playbackSettings  => _t('playbackSettings');
  String get muteByDefault     => _t('muteByDefault');
  String get muteByDefaultDesc => _t('muteByDefaultDesc');
  String get screenFit         => _t('screenFit');
  String get fitCover          => _t('fitCover');
  String get fitCoverDesc      => _t('fitCoverDesc');
  String get fitContain        => _t('fitContain');
  String get fitContainDesc    => _t('fitContainDesc');
  String get fitAuto           => _t('fitAuto');
  String get fitAutoDesc       => _t('fitAutoDesc');
  String get themeColor        => _t('themeColor');
  String get selectAccentColor => _t('selectAccentColor');
  String get hiddenVideos      => _t('hiddenVideos');
  String get noHiddenVideos    => _t('noHiddenVideos');
  String get clearCache        => _t('clearCache');
  String get clearCacheDesc    => _t('clearCacheDesc');
  String get about             => _t('about');
  String get language          => _t('language');
  String get selectLanguage    => _t('selectLanguage');

  // ── Album Picker ─────────────────────────────────────────────
  String get allAlbums         => _t('allAlbums');
  String get selectFolder      => _t('selectFolder');
  String get videos            => _t('videos');

  // ── Dialogs ───────────────────────────────────────────────────
  String get hideVideoTitle    => _t('hideVideoTitle');
  String get hideVideoDesc     => _t('hideVideoDesc');
  String get cacheCleared      => _t('cacheCleared');
  String get cacheClearError   => _t('cacheClearError');
  String get videoRestored     => _t('videoRestored');

  // ── Color names ───────────────────────────────────────────────
  String get colorRed    => _t('colorRed');
  String get colorCyan   => _t('colorCyan');
  String get colorGold   => _t('colorGold');
  String get colorPurple => _t('colorPurple');
  String get colorGreen  => _t('colorGreen');

  // ── Language names ────────────────────────────────────────────
  String get langTurkish  => _t('langTurkish');
  String get langEnglish  => _t('langEnglish');
  String get langTurkmen  => _t('langTurkmen');
  String get langRussian  => _t('langRussian');

  // ── String tables ─────────────────────────────────────────────
  static const Map<String, Map<String, String>> _strings = {
    // ── TURKISH ──────────────────────────────────────────────────
    'tr': {
      'discover':        'Keşfet',
      'favorites':       'Favoriler',
      'settings':        'Ayarlar',
      'like':            'Beğen',
      'liked':           'Beğenildi',
      'hide':            'Gizle',
      'share':           'Paylaş',
      'mute':            'Sessiz',
      'sound':           'Ses',
      'cancel':          'Vazgeç',
      'retry':           'Tekrar Dene',
      'restore':         'Geri Al',
      'loadingVideos':   'Videolar yükleniyor...',
      'noVideos':        'Hiç video bulunamadı',
      'noVideosDesc':    'Galerinizde video yok veya tüm videolar gizlendi.',
      'galleryError':    'Galeri yüklenemedi',
      'nextVideo':       'Sonraki video',
      'playbackSettings':'Oynatma Ayarları',
      'muteByDefault':   'Başlangıçta Sessiz',
      'muteByDefaultDesc':'Videolar sessiz başlasın',
      'screenFit':       'Ekran Sığdırma',
      'fitCover':        'Ekranı Kapla',
      'fitCoverDesc':    'Kırparak doldur',
      'fitContain':      'Tam Göster',
      'fitContainDesc':  'Sığdırarak göster',
      'fitAuto':         'Otomatik',
      'fitAutoDesc':     'Video yönüne göre',
      'themeColor':      'Tema Rengi',
      'selectAccentColor':'Vurgu rengini seç',
      'hiddenVideos':    'Gizlenen Videolar',
      'noHiddenVideos':  'Gizlenmiş video yok',
      'clearCache':      'Önbelleği Temizle',
      'clearCacheDesc':  'Geçici dosyaları temizler',
      'about':           'Uygulama Hakkında',
      'language':        'Dil',
      'selectLanguage':  'Dil seçin',
      'allAlbums':       'Tüm Videolar',
      'selectFolder':    'Klasör Seç',
      'videos':          'video',
      'hideVideoTitle':  'Bu videoyu gizle?',
      'hideVideoDesc':   'Video akışında bir daha gösterilmeyecek. Bu işlem geri alınabilir (Ayarlar).',
      'cacheCleared':    'Önbellek temizlendi ✓',
      'cacheClearError': 'Önbellek temizlenemedi.',
      'videoRestored':   'Video akışa geri döndürüldü',
      'colorRed':        'Kırmızı',
      'colorCyan':       'Cyan',
      'colorGold':       'Altın',
      'colorPurple':     'Mor',
      'colorGreen':      'Yeşil',
      'langTurkish':     'Türkçe',
      'langEnglish':     'İngilizce',
      'langTurkmen':     'Türkmence',
      'langRussian':     'Rusça',
    },

    // ── ENGLISH ───────────────────────────────────────────────────
    'en': {
      'discover':        'Discover',
      'favorites':       'Favorites',
      'settings':        'Settings',
      'like':            'Like',
      'liked':           'Liked',
      'hide':            'Hide',
      'share':           'Share',
      'mute':            'Mute',
      'sound':           'Sound',
      'cancel':          'Cancel',
      'retry':           'Retry',
      'restore':         'Restore',
      'loadingVideos':   'Loading videos...',
      'noVideos':        'No videos found',
      'noVideosDesc':    'No videos in gallery or all videos are hidden.',
      'galleryError':    'Gallery could not be loaded',
      'nextVideo':       'Next video',
      'playbackSettings':'Playback Settings',
      'muteByDefault':   'Mute by Default',
      'muteByDefaultDesc':'Videos start muted',
      'screenFit':       'Screen Fit',
      'fitCover':        'Fill Screen',
      'fitCoverDesc':    'Crop to fill',
      'fitContain':      'Show All',
      'fitContainDesc':  'Fit without cropping',
      'fitAuto':         'Auto',
      'fitAutoDesc':     'Based on video orientation',
      'themeColor':      'Theme Color',
      'selectAccentColor':'Select accent color',
      'hiddenVideos':    'Hidden Videos',
      'noHiddenVideos':  'No hidden videos',
      'clearCache':      'Clear Cache',
      'clearCacheDesc':  'Remove temporary files',
      'about':           'About',
      'language':        'Language',
      'selectLanguage':  'Select language',
      'allAlbums':       'All Videos',
      'selectFolder':    'Select Folder',
      'videos':          'videos',
      'hideVideoTitle':  'Hide this video?',
      'hideVideoDesc':   'This video won\'t appear in the feed. You can undo this in Settings.',
      'cacheCleared':    'Cache cleared ✓',
      'cacheClearError': 'Cache could not be cleared.',
      'videoRestored':   'Video restored to feed',
      'colorRed':        'Red',
      'colorCyan':       'Cyan',
      'colorGold':       'Gold',
      'colorPurple':     'Purple',
      'colorGreen':      'Green',
      'langTurkish':     'Turkish',
      'langEnglish':     'English',
      'langTurkmen':     'Turkmen',
      'langRussian':     'Russian',
    },

    // ── TURKMEN ───────────────────────────────────────────────────
    'tk': {
      'discover':        'Açyş',
      'favorites':       'Halaýanlar',
      'settings':        'Sazlamalar',
      'like':            'Halama',
      'liked':           'Halanan',
      'hide':            'Gizle',
      'share':           'Paýlaş',
      'mute':            'Ses ýok',
      'sound':           'Ses',
      'cancel':          'Ýatyr',
      'retry':           'Gaýtala',
      'restore':         'Gaýtar',
      'loadingVideos':   'Wideolar ýüklenýär...',
      'noVideos':        'Wideo tapylmady',
      'noVideosDesc':    'Galereiňizde wideo ýok ýa-da hemmesi gizlendi.',
      'galleryError':    'Galerei ýüklenip bilinmedi',
      'nextVideo':       'Indiki wideo',
      'playbackSettings':'Oýnatma sazlamalary',
      'muteByDefault':   'Sessiz başla',
      'muteByDefaultDesc':'Wideolar sessiz başlar',
      'screenFit':       'Ekran laýyklygy',
      'fitCover':        'Ekrany doldur',
      'fitCoverDesc':    'Kesmek bilen doldur',
      'fitContain':      'Hemmesini göster',
      'fitContainDesc':  'Kesmezden laýyklaşdyr',
      'fitAuto':         'Awtomatik',
      'fitAutoDesc':     'Wideo ugruna görä',
      'themeColor':      'Tema reňki',
      'selectAccentColor':'Urgu reňkini saýla',
      'hiddenVideos':    'Gizlenen wideolar',
      'noHiddenVideos':  'Gizlenen wideo ýok',
      'clearCache':      'Keşi arassala',
      'clearCacheDesc':  'Wagtlaýyn faýllary arassalar',
      'about':           'Programma barada',
      'language':        'Dil',
      'selectLanguage':  'Dili saýla',
      'allAlbums':       'Ähli wideolar',
      'selectFolder':    'Bukja saýla',
      'videos':          'wideo',
      'hideVideoTitle':  'Bu wideony gizle?',
      'hideVideoDesc':   'Bu wideo akymda görkezilmez. Sazlamalarda yzyna gaýdyp bolýar.',
      'cacheCleared':    'Keş arassalandy ✓',
      'cacheClearError': 'Keş arassalanyp bilinmedi.',
      'videoRestored':   'Wideo akymyna gaýtaryldy',
      'colorRed':        'Gyzyl',
      'colorCyan':       'Siýan',
      'colorGold':       'Altyn',
      'colorPurple':     'Melewşe',
      'colorGreen':      'Ýaşyl',
      'langTurkish':     'Türkçe',
      'langEnglish':     'Iňlis dili',
      'langTurkmen':     'Türkmen dili',
      'langRussian':     'Rus dili',
    },

    // ── RUSSIAN ───────────────────────────────────────────────────
    'ru': {
      'discover':        'Обзор',
      'favorites':       'Избранное',
      'settings':        'Настройки',
      'like':            'Нравится',
      'liked':           'Понравилось',
      'hide':            'Скрыть',
      'share':           'Поделиться',
      'mute':            'Без звука',
      'sound':           'Звук',
      'cancel':          'Отмена',
      'retry':           'Повторить',
      'restore':         'Восстановить',
      'loadingVideos':   'Загрузка видео...',
      'noVideos':        'Видео не найдено',
      'noVideosDesc':    'В галерее нет видео или все скрыты.',
      'galleryError':    'Не удалось загрузить галерею',
      'nextVideo':       'Следующее видео',
      'playbackSettings':'Настройки воспроизведения',
      'muteByDefault':   'Без звука по умолчанию',
      'muteByDefaultDesc':'Видео начинается без звука',
      'screenFit':       'Размер экрана',
      'fitCover':        'Заполнить экран',
      'fitCoverDesc':    'Обрезать для заполнения',
      'fitContain':      'Показать всё',
      'fitContainDesc':  'Вместить без обрезки',
      'fitAuto':         'Авто',
      'fitAutoDesc':     'По ориентации видео',
      'themeColor':      'Цвет темы',
      'selectAccentColor':'Выберите акцентный цвет',
      'hiddenVideos':    'Скрытые видео',
      'noHiddenVideos':  'Нет скрытых видео',
      'clearCache':      'Очистить кэш',
      'clearCacheDesc':  'Удалить временные файлы',
      'about':           'О приложении',
      'language':        'Язык',
      'selectLanguage':  'Выберите язык',
      'allAlbums':       'Все видео',
      'selectFolder':    'Выбрать папку',
      'videos':          'видео',
      'hideVideoTitle':  'Скрыть это видео?',
      'hideVideoDesc':   'Видео не будет отображаться в ленте. Можно отменить в Настройках.',
      'cacheCleared':    'Кэш очищен ✓',
      'cacheClearError': 'Не удалось очистить кэш.',
      'videoRestored':   'Видео возвращено в ленту',
      'colorRed':        'Красный',
      'colorCyan':       'Голубой',
      'colorGold':       'Золотой',
      'colorPurple':     'Фиолетовый',
      'colorGreen':      'Зелёный',
      'langTurkish':     'Турецкий',
      'langEnglish':     'Английский',
      'langTurkmen':     'Туркменский',
      'langRussian':     'Русский',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  static const _supported = ['tr', 'en', 'tk', 'ru'];

  @override
  bool isSupported(Locale locale) =>
      _supported.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
