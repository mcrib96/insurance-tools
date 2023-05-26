<template>
  <div class="mt-4">
    <tr>
      <td cols="12">
        <v-chip
          class="mr-2"
          :class="selectedSheet === sheet ? 'active' : ''"
          v-for="sheet in spreadsheet.SheetNames"
          :key="sheet"
          @click="selectSheet(sheet)"
        >
          {{ sheet }}
        </v-chip>
      </td>
    </tr>
    <div v-for="sheet in spreadsheet.SheetNames" :key="sheet" class="mt-2">
      <div v-if="selectedSheet === sheet">
        <table border="1">
          <thead>
            <tr class="flex-nowrap bg-white">
              <th v-for="header in headers" :key="header">
                {{ header }}<br />
                <select
                  @change="changeFieldMapping(header, $event)"
                  title="Where should this go on the Acord 140?"
                >
                  <option value="" selected class="default_option">
                    Choose
                  </option>
                  <option
                    :value="field.field"
                    v-for="(field, i) in fieldsToMap"
                    :key="i"
                  >
                    {{ field.label }}
                  </option>
                </select>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="i in maxRows" :index="i">
              <td v-for="header in headers" :key="header">
                {{
                  formattedData[header][i - 1]
                    ? formattedData[header][i - 1]
                    : "&nbsp;"
                }}
              </td>
            </tr>
          </tbody>
        </table>
        <v-btn @click="finishMapping">Finished Mapping</v-btn>
      </div>
    </div>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive } from "vue";

const props = defineProps({
  spreadsheet: {
    type: Object,
    required: true,
  },
});
const emit = defineEmits<{
  (e: "data-mapped", data: any): void;
}>();

const selectedSheet = ref("");
const fieldsToMap: any[] = [
  { label: "Effective Date", field: "effective_date", assigned_field: [] },
  { label: "Premises #", field: "premises_number", assigned_field: [] },
  { label: "Building #", field: "building_number", assigned_field: [] },
  { label: "Street Address", field: "street_address", assigned_field: [] },
  {
    label: "Building Description",
    field: "building_description",
    assigned_field: [],
  },
  {
    label: "Building Value (Subject of Insurance)",
    field: "building_value_soi",
    assigned_field: [],
  },
  { label: "Building Value (Amount)", field: "bv_amount", assigned_field: [] },
  { label: "Building Value (Coins %)", field: "bv_coins", assigned_field: [] },
  {
    label: "Building Value (Valuation)",
    field: "bv_valuation",
    assigned_field: [],
  },
  {
    label: "Building Value (Causes of Loss)",
    field: "bv_causes_of_loss",
    assigned_field: [],
  },
  {
    label: "Building Value (Inflation Guard)",
    field: "bv_inflation_guard",
    assigned_field: [],
  },
  { label: "Building Value (DED)", field: "bv_ded", assigned_field: [] },
  {
    label: "Building Value (DED Type)",
    field: "bv_ded_type",
    assigned_field: [],
  },
  { label: "Building Value (BLKT #)", field: "bv_blkt", assigned_field: [] },
  {
    label: "Building Value (Forms and Conditions)",
    field: "bv_forms_conditions",
    assigned_field: [],
  },
  {
    label: "Rental Income (Subject of Insurance)",
    field: "rental_income_soi",
    assigned_field: [],
  },
  { label: "Rental Income (Amount)", field: "ri_amount", assigned_field: [] },
  { label: "Rental Income (Coins %)", field: "ri_coins", assigned_field: [] },
  {
    label: "Rental Income (Valuation)",
    field: "ri_valuation",
    assigned_field: [],
  },
  {
    label: "Rental Income (Causes of Loss)",
    field: "ri_causes_of_loss",
    assigned_field: [],
  },
  {
    label: "Rental Income (Inflation Guard)",
    field: "ri_inflation_guard",
    assigned_field: [],
  },
  { label: "Rental Income (DED)", field: "ri_ded", assigned_field: [] },
  {
    label: "Rental Income (DED Type)",
    field: "ri_ded_type",
    assigned_field: [],
  },
  { label: "Rental Income (BLKT #)", field: "ri_blkt", assigned_field: [] },
  {
    label: "Rental Income (Forms and Conditions)",
    field: "ri_forms_conditions",
    assigned_field: [],
  },
  { label: "Wiring", field: "cb_wiring", assigned_field: [] },
  { label: "Wiring Year", field: "year_wiring", assigned_field: [] },
  { label: "Roofing", field: "cb_roofing", assigned_field: [] },
  { label: "Roofing Year", field: "year_roofing", assigned_field: [] },
  { label: "Plumbing", field: "cb_plumbing", assigned_field: [] },
  { label: "Plumbing Year", field: "year_plumbing", assigned_field: [] },
  { label: "Heating", field: "cb_heating", assigned_field: [] },
  { label: "Heating Year", field: "year_heating", assigned_field: [] },
  { label: "Roof Type", field: "roof_type", assigned_field: [] },
  { label: "Stories", field: "stories", assigned_field: [] },
  { label: "Basements", field: "basements", assigned_field: [] },
  { label: "Year Built", field: "year_built", assigned_field: [] },
  { label: "Total Area", field: "total_area", assigned_field: [] },
  {
    label: "Construction Type",
    field: "construction_type",
    assigned_field: [],
  },
];
const headers: any = ref([]);
const columnToHeader: any = reactive({});
const formattedData: any = ref([]);
let maxRows = ref<number>(0);
const sheetData = ref<any>(null);

const selectSheet = (sheet: string) => {
  selectedSheet.value = sheet;
  sheetData.value = null;
  sheetData.value = props.spreadsheet.Sheets[sheet];
  headers.value = [];
  formattedData.value = [];
  maxRows.value = 0;
  const pattern = RegExp(/([A-Z]+)(\d+)/);
  if (sheetData.value) {
    Object.keys(sheetData.value).forEach((item: string) => {
      if (!["!autofilter", "!margins", "!ref"].includes(item)) {
        const parts = item.match(pattern);
        const o = sheetData?.value[item];
        if (parts !== null && parts.length > 2) {
          // This is a header
          if (parts[2] === "1") {
            headers.value.push(o.w);
            columnToHeader[parts[1]] = o.w;
            formattedData.value[o.w] = [];
          } else {
            // This is data for the header
            const header = columnToHeader[parts[1]];
            formattedData.value[header].push(o.w);
          }
        }
      }
    });
    headers.value.forEach((header: string) => {
      if (formattedData.value[header].length > maxRows.value) {
        maxRows.value = formattedData.value[header].length;
      }
    });
  }
};
const changeFieldMapping = (header: string, e: any) => {
  const mappedField = e.target.value;
  fieldsToMap.forEach((o: any) => {
    if (mappedField === "") {
      if (o.assigned_field.includes(header)) {
        const index = o.assigned_field.findIndex(
          (field: string) => field === header
        );
        o.assigned_field.splice(index, 1);
      }
    } else {
      if (o.field === mappedField) {
        o.assigned_field.push(header);
      }
    }
  });
};
const finishMapping = () => {
  const mappedData: any = {};
  fieldsToMap.forEach((o: any) => {
    mappedData[o.field] = [];
    for (let i = 0; i < maxRows.value; i++) {
      const c: any[] = [];
      o.assigned_field.forEach((s: string) => {
        c.push(formattedData.value[s][i] ? formattedData.value[s][i] : "");
      });
      mappedData[o.field].push(c.join(" "));
    }
  });
  emit("data-mapped", mappedData);
};
</script>
<style scoped>
.active {
  background-color: #ffff00;
}
select {
  background-color: #bbbbbb;
  max-width: 75px;
}
table {
  display: block;
  max-width: 75vw;
  max-height: 70vh;
  overflow: auto;
}
</style>
