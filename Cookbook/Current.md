# How to use `Current` in Babylon iOS Project

### Where is that? 
- `Current` is the global instance of the `World` type which is located in the `BabylonDependencies.framework`. 
It's purpose is to provide convenient access to the instances that should be shared between different parts of the app (cross-cutting concerns). For more information please read the [How Control the World](/Cookbook/Proposals/ControlTheWorld.md) document.

## `Do`s and `Don't`s

#### do
- access `Current` **only** from `Builder`s layer;
- pass the required dependencies down the chain;
- contribute to it;

#### don't
- access `Current` from any other layer other than `Builder`. I.E all the other layers (ViewModel, Flowcontroller, ViewController, Model, BusinessController) continue to receive its dependencies throught injection, preferably via `init`;
- inject `current` as a dependency;
- try to mutate `Current`. In `Release` configuration it's a constant `let`;

