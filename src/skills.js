const SKILLS = [
  {
    name: 'swiftui-pro',
    description: 'SwiftUI — state management, NavigationStack, layout, performance, accessibility (iOS 26 / Swift 6)',
  },
  {
    name: 'swift-concurrency-pro',
    description: 'Swift Concurrency — async/await, Sendable, actors, strict concurrency, Swift 6 migration',
  },
  {
    name: 'swift-architecture-pro',
    description: 'iOS Architecture — MVVM with @Observable, dependency injection, navigation routing, modularization',
  },
  {
    name: 'swift-language-pro',
    description: 'Swift Language — value vs reference types, optionals, error handling, generics, protocols',
  },
  {
    name: 'swift-testing-pro',
    description: 'Swift Testing — @Test, expectations, parameterized tests, mocking, test organization',
  },
  {
    name: 'swift-performance-pro',
    description: 'Swift Performance — render cost, memory/retain cycles, slow lists, launch time, Instruments',
  },
  {
    name: 'swift-accessibility-pro',
    description: 'Accessibility — VoiceOver, Dynamic Type, color contrast, Reduce Motion, accessibility testing',
  },
  {
    name: 'swift-security-pro',
    description: 'iOS Security — Keychain, Data Protection, ATS/TLS, secrets management, biometric auth',
  },
  {
    name: 'core-data-pro',
    description: 'Core Data — entity modeling, NSPersistentContainer, background contexts, batch operations, migrations',
  },
  {
    name: 'swiftdata-pro',
    description: 'SwiftData — @Model, @Query, ModelContainer, migrations, CloudKit sync (iOS 17+)',
  },
  {
    name: 'app-intents-pro',
    description: 'App Intents — Siri, Shortcuts, Spotlight with AppIntent, parameters, AppEntity',
  },
];

function findSkill(name) {
  return SKILLS.find(s => s.name === name);
}

function allSkillNames() {
  return SKILLS.map(s => s.name);
}

module.exports = { SKILLS, findSkill, allSkillNames };
