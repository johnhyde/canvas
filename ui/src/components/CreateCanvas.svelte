<script lang="ts">
  import {
    Modal,
    FormGroup,
    Button,
    ButtonSet,
    Grid,
    Row,
    Column,
    RadioButton,
    TextInput,
    RadioButtonGroup,
    Checkbox,
    Select,
    SelectItem,
    SelectItemGroup,
    Form
  } from 'carbon-components-svelte';
  import Paint32 from 'carbon-icons-svelte/lib/PaintBrush32';

  import { Sveltik, Field } from 'sveltik';
  import store from '../store';
  import { stringToSymbol } from '$lib/utils';
  import type { CanvasForm } from '../types/canvas';

  import MeshPreview from './MeshPreview.svelte';

  const hexaTemplates = {
    'mesh-welcome': 'Canvas ~ Urbit',
    'mesh-hackathon': 'Urbit Hackathon',
    'mesh-homer': 'Homer Simpson'
  };

  const squareTemplates = {
    'mesh-monkey': 'Monkey Island',
    'mesh-dumas': 'Dumas-Dutil Cosmic Call'
  };

  const performanceWarning =
    'Mesh grids with many pixels could affect performance';

  let open = false,
    isSubmitting = false,
    checkbox;

  const initialValues = {
    name: '',
    mesh: 'squa',
    private: true,
    template: 'mesh'
    // width: 1500,
    // height: 1000
  };

  const initialWarnings = {
    width: performanceWarning,
    height: performanceWarning
  };

  function validate(values: CanvasForm) {
    const errors = { name: '', width: '', height: '' };
    if (values.name === '') {
      errors.name = 'Name Required';
    }
    if (
      $store.privateCanvas.includes(
        `~${$store.ship}/${stringToSymbol(values.name)}`
      ) ||
      $store.publicCanvas.includes(
        `~${$store.ship}/${stringToSymbol(values.name)}`
      )
    ) {
      errors.name = 'Canvas Title already exists...';
    }
    if (values.template == 'mesh' && values.width < 648) {
      errors.width = 'Min width 648';
    }
    if (values.template == 'mesh' && values.width > 1890) {
      errors.width = 'Max width 1890';
    }
    if (values.template == 'mesh' && values.height < 648) {
      errors.height = 'Min height 648';
    }
    if (values.template == 'mesh' && values.height > 1890) {
      errors.height = 'Max height 1890';
    }
    if (values.template == 'mesh' && !values.width) {
      errors.width = 'Width required';
    }
    if (values.template == 'mesh' && !values.height) {
      errors.height = 'Height required';
    }
    return errors;
  }

  function onSubmit(values: CanvasForm, { setSubmitting }) {
    console.log('[ creating canvas... ]', values);
    const canvasName = stringToSymbol(values.name);
    const dx = $store.radius * 2 * Math.sin(Math.PI / 3);
    const columns = values.width ? Math.ceil(values.width / dx) + 1 : 0;
    $store.api
      .create(
        canvasName,
        '~' + $store.ship,
        values.template,
        values.private,
        values.width ? values.width : 0,
        values.height ? values.height : 0,
        columns,
        values.mesh
      )
      .then(() => {
        console.log('[ success new canvas... ]', values.name);
        open = false;
        isSubmitting = false;
      });
  }
</script>

<Button icon={Paint32} kind="ghost" size="small" on:click={() => (open = true)}>
  New
</Button>

<Modal bind:open modalHeading="" passiveModal size="sm" hasForm={true}>
  <Grid padding>
    <Sveltik
      let:props
      let:values
      let:setFieldWarning
      {initialValues}
      {initialWarnings}
      {validate}
      {onSubmit}
      bind:isSubmitting>
      <Form on:submit={props.handleSubmit} {...props}>
        <FormGroup legendText="Canvas">
          <Row>
            <Column>
              <Field let:field let:meta name="name">
                <TextInput
                  inline
                  size="sm"
                  light
                  labelText="Title"
                  placeholder="Name your creation!"
                  {...field}
                  invalid={meta.error}
                  type="text"
                  invalidText={meta.error}
                  on:input={field.handleInput}
                  on:blur={field.handleBlur} />
              </Field>
            </Column>
            <Column padding lg={4}>
              <Field let:field let:meta name="private">
                <Checkbox
                  style={'display: inline-block;'}
                  labelText="Private"
                  ref={checkbox}
                  checked={initialValues.private}
                  {...field}
                  title="Uncheck if you want others to join"
                  on:change={field.handleInput}
                  on:blur={field.handleBlur} />
              </Field>
            </Column>
          </Row>
        </FormGroup>
        <!-- <FormGroup legendText="Mesh"> -->
        <!-- </FormGroup> -->
        <FormGroup legendText="Options">
          <Row>
            <Column>
              <Field let:field name="mesh">
                <RadioButtonGroup
                  selected={initialValues.mesh}
                  on:change={vals => {
                    if (!vals.detail) return;
                    const target = { name: 'mesh', value: vals.detail };
                    return field.handleInput({ target });
                  }}>
                  <MeshPreview
                    width="48"
                    height="44"
                    stroke="black"
                    strokeWidth="0.7"
                    fill="none"
                    type="squa" />
                  <RadioButton type="radio" labelText="Squares" value="squa" />
                  <MeshPreview
                    width="48"
                    height="44"
                    stroke="black"
                    strokeWidth="0.9"
                    fill="none"
                    type="hexa" />
                  <RadioButton type="radio" labelText="Hexagons" value="hexa" />
                </RadioButtonGroup>
              </Field>
            </Column>
          </Row>
          <Row>
            <Column>
              <Field let:field let:meta name="width">
                <TextInput
                  type="number"
                  size="sm"
                  light
                  labelText="Width"
                  {...field}
                  invalid={meta.error}
                  invalidText={meta.error}
                  warn={field.value > 1500}
                  warnText={meta.warning}
                  on:input={field.handleInput}
                  on:blur={field.handleBlur} />
              </Field>
            </Column>
            <Column>
              <Field
                let:field
                let:meta
                name="height"
                initialWarning={performanceWarning}>
                <TextInput
                  type="number"
                  size="sm"
                  light
                  labelText="Height"
                  {...field}
                  warn={field.value > 1000}
                  warnText={meta.warning}
                  invalid={meta.error}
                  invalidText={meta.error}
                  on:input={field.handleInput}
                  on:blur={field.handleBlur} />
              </Field>
            </Column>
          </Row>
        </FormGroup>
        <FormGroup legendText="Choose from a custom template">
          <Row>
            <Column>
              <Field let:field name="template">
                <!-- {#each Object.keys(templates) as template}
              <option value={template}>
                {template}
              </option>
            {/each} -->

                <Select
                  light
                  size="sm"
                  inline
                  on:change={vals => {
                    if (!vals.detail) return;
                    const target = { name: 'template', value: vals.detail };
                    return field.handleInput({ target });
                  }}>
                  <SelectItem value="mesh" text="No Template" />
                  <SelectItemGroup label="Hexagonal">
                    {#each Object.entries(hexaTemplates) as [template, name]}
                      <SelectItem value={template} text={name} />
                    {/each}
                  </SelectItemGroup>
                  <SelectItemGroup label="Square">
                    {#each Object.entries(squareTemplates) as [template, name]}
                      <SelectItem value={template} text={name} />
                    {/each}
                  </SelectItemGroup>
                </Select>
              </Field>
            </Column>
          </Row>
        </FormGroup>
        <!-- <FormGroup> -->
        <!-- <Row> -->
        <!-- <Column> -->
        <ButtonSet>
          <Button on:click={() => (open = false)} kind="secondary">
            Cancel
          </Button>
          <Button type="submit" disabled={isSubmitting}>Submit</Button>
        </ButtonSet>
        <!-- </Column> -->
        <!-- </Row> -->
        <!-- </FormGroup> -->
      </Form>
    </Sveltik>
  </Grid>
</Modal>
