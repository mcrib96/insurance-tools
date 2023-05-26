import { createApp } from 'vue'
import App from './App.vue'
import { createVuetify } from 'vuetify'
import router from './router'
import 'vuetify/styles'
import './style.css'

const vuetify = createVuetify()
createApp(App).use(vuetify).use(router).mount('#app')
