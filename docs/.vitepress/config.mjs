import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Nova",
  description: "A filesystem-based web framework for Luau runtimes, with out-of-the-box support for Lute, Lune and Zune.",
  head: [['link', { rel: 'icon', href: '/nova/favicon.ico' }]],
  base: "/nova/",
  themeConfig: {
    search: {
      provider: 'local'
    },
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Blog', link: '/docs/blog/changelog' },
      { text: 'Luau Guides', link: '/luau-guides/introduction' }
    ],

    sidebar: {
      '/docs/': [
        {
          text: 'Introduction',
          items: [
            { text: 'What is Nova?', link: '/docs/introduction/what-is-nova' },
            { text: 'Getting Started', link: '/docs/introduction/getting-started' }
          ]
        },
        {
          text: 'Guides',
          items: [
            { text: 'Project Stucture', link: '/docs/guides/project-structure' },
            { text: 'Routing', link: '/docs/guides/routing' },
            { text: 'Request & Response', link: '/docs/guides/req-res' },
            {
                text: 'Middleware',
                link: '/docs/guides/middleware',
                items: [
                    { text: 'Guard', link: '/docs/guides/middleware/guard' },
                    { text: 'Validator', link: '/docs/guides/middleware/validator' },
                    { text: 'Interceptor', link: '/docs/guides/middleware/interceptor' },
                    
                ]
            },
            { text: 'Exception', link: '/docs/guides/exception' },
          ]
        },
        {
          text: 'Blog',
          items: [
            { text: 'Changelog', link: '/docs/blog/changelog' }
          ]
        }
      ],
      '/luau-guides/': [
        {
          text: 'The Basics of Luau',
          items: [
            { text: 'Introduction', link: '/luau-guides/introduction' },
            { text: 'Your First Program', link: '/luau-guides/your-first-program' },
            { text: 'Variables & Data Types', link: '/luau-guides/vars-and-datatypes' },
            { text: 'Basic Math & Logic', link: '/luau-guides/basic-math-and-logic' },
            { text: 'The Luau Upgrades', link: '/luau-guides/the-luau-upgrades' },
            { text: 'Condition Flow', link: '/luau-guides/condition-flow' },
            { text: 'Loops', link: '/luau-guides/loops' },
            { text: 'Functions', link: '/luau-guides/functions' },
            { text: 'Tables', link: '/luau-guides/tables' },
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/nova-guild/nova' }
    ],
    editLink: {
        pattern: 'https://github.com/nova-guild/nova/edit/main/docs/:path',
        text: 'Edit this page on GitHub'
    }
  }
})
