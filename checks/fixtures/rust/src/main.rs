// Local types and a macro keep language-server checks independent of the network.
macro_rules! answer {
    () => { 42 };
}
struct Item {
    value: i32,
}
fn main() {
    let item = Item { value: answer!() };
    let _ = item.value;
}
