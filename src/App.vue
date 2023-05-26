<template>
  <div>
    <v-layout>
      <v-app-bar>
        <h1 class="ml-6">Insurance Tools for Jennifer</h1>
      </v-app-bar>
      <v-navigation-drawer permanent theme="light">
        <v-list nav>
          <v-list-item
            title="Home"
            value="Home"
            nav
            :to="{ name: 'Home' }"
          ></v-list-item>
          <v-list-item
            title="About"
            value="About"
            nav
            :to="{ name: 'About' }"
          ></v-list-item>
          <v-list-item
            title="Acord 140"
            value="Acord 140"
            nav
            :to="{ name: 'Forms' }"
          ></v-list-item>
          <v-list-item
            title="Acord 27 EOI"
            value="Acord 27 EOI"
            nav
            :to="{ name: 'EOI27' }"
          ></v-list-item>
          <v-list-item
            title="Acord 25 COI"
            value="Acord 25 COI"
            nav
            :to="{ name: 'COI25' }"
          ></v-list-item>
        </v-list>
      </v-navigation-drawer>
      <v-main>
        <RouterView class="scrollable"></RouterView>
      </v-main>
    </v-layout>
  </div>
</template>
<script setup lang="ts"></script>
<style scoped>
.scrollable {
  overflow: auto;
}
</style>
