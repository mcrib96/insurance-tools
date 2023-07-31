<template>
  <div class="mt-4">
    <tr>
      <td cols="12">
        Click on the sheet =>
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
                {{ header }}
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
  { label: "Date", field: "date", assigned_field: ["date"] },
  { label: "Company", field: "company", assigned_field: ["company"] },
  { label: "Insured", field: "insured", assigned_field: ["insured"] },
  { label: "Loan #", field: "loan_number", assigned_field: ["loan_number"] },
  {
    label: "Policy #",
    field: "policy_number",
    assigned_field: ["policy_number"],
  },
  {
    label: "Effective Date",
    field: "effective_date",
    assigned_field: ["effective_date"],
  },
  {
    label: "Expiration Date",
    field: "expiration_date",
    assigned_field: ["expiration_date"],
  },
  {
    label: "Continue Until Terminated",
    field: "continue_until_terminated",
    assigned_field: ["continue_until_terminated"],
  },
  {
    label: "Location",
    field: "location",
    assigned_field: ["address", "city", "state", "zip"],
  },
  {
    label: "Description",
    field: "description",
    assigned_field: ["description"],
  },
  { label: "Perils - Basic", field: "basic", assigned_field: ["perils_basic"] },
  { label: "Perils - Broad", field: "broad", assigned_field: ["perils_broad"] },
  {
    label: "Perils - Special",
    field: "special",
    assigned_field: ["perils_special"],
  },
  {
    label: "Coverage Information",
    field: "coverage_information",
    assigned_field: ["coverage_information"],
  },
  {
    label: "Amount of Insurance",
    field: "amount_of_insurance",
    assigned_field: ["amount_of_insurance"],
  },
  { label: "Deductible", field: "deductible", assigned_field: ["deductible"] },
  { label: "Remarks", field: "remarks", assigned_field: ["remarks"] },
  {
    label: "Additional Interest",
    field: "additional_interest",
    assigned_field: ["additional_interest"],
  },
  {
    label: "Additional Insured",
    field: "additional_insured",
    assigned_field: ["additional_insured"],
  },
  {
    label: "Lenders Loss Payable",
    field: "lenders_loss_payable",
    assigned_field: ["lenders_loss_payable"],
  },
  { label: "Loss Payee", field: "loss_payee", assigned_field: ["loss_payee"] },
  { label: "Mortgagee", field: "mortgagee", assigned_field: ["mortgagee"] },
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
